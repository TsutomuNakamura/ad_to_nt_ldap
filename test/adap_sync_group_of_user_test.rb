require "test_helper"

class ModAdapTest < Minitest::Test
  def test_sync_group_of_user_should_call_ldap_client_search_without_gidfilter_if_parameter_of_gid_is_nil
    mock                            = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result  = mock()
    mock_ldap_get_operation_result  = mock()

    Net::LDAP::Filter.expects(:construct).with(
      "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com))"  # Tset
    ).returns("(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com))")

    # @ldap_client.modify
    mock[:ad_client].expects(:search).with({
      :base => "DC=mysite,DC=example,DC=com",
      :filter => "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com))"
    }).yields({:name => "Domain Users"})

    mock_ad_get_operation_result.expects(:code).returns(0)
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    Net::LDAP::Filter.expects(:construct)
      .with("(memberUid=foo)")
      .returns("(memberUid=foo)")
    mock[:ldap_client].expects(:search).with({
      :base => "ou=Users,dc=mysite,dc=example,dc=com", :filter => "(memberUid=foo)"
    }).yields({:cn => "Domain Users"})

    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = Adap.new({
      :ad_host        => "localhost",
      :ad_binddn      => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_basedn      => "DC=mysite,DC=example,DC=com",
      :ad_password    => "ad_secret",
      :ldap_host      => "ldap_server",
      :ldap_binddn    => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_basedn    => "dc=mysite,dc=example,dc=com",
      :ldap_password  => "ldap_secret"
    })
    ret = adap.sync_group_of_user("foo", nil)
    assert_equal({:code => 0, :operations => [:modify_group_of_user], :message => "There are not any groups of user to sync"}, ret)
  end

  def test_sync_group_of_user_should_call_ldap_client_search_with_gidfilter_if_parameter_of_gid_is_not_nil
    mock                            = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result  = mock()
    mock_ldap_get_operation_result  = mock()

    Net::LDAP::Filter.expects(:construct).with(
      "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))"
    ).returns("(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))")

    # @ldap_client.modify
    mock[:ad_client].expects(:search).with({
      :base => "DC=mysite,DC=example,DC=com",
      :filter => "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))"
    }).yields({:name => "Domain Users"})

    mock_ad_get_operation_result.expects(:code).returns(0)
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    Net::LDAP::Filter.expects(:construct)
      .with("(memberUid=foo)")
      .returns("(memberUid=foo)")
    mock[:ldap_client].expects(:search).with({
      :base => "ou=Users,dc=mysite,dc=example,dc=com", :filter => "(memberUid=foo)"
    }).yields({:cn => "Domain Users"})

    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = Adap.new({
      :ad_host        => "localhost",
      :ad_binddn      => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_basedn      => "DC=mysite,DC=example,DC=com",
      :ad_password    => "ad_secret",
      :ldap_host      => "ldap_server",
      :ldap_binddn    => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_basedn    => "dc=mysite,dc=example,dc=com",
      :ldap_password  => "ldap_secret"
    })
    ret = adap.sync_group_of_user("foo", 513)
    assert_equal({:code => 0, :operations => [:modify_group_of_user], :message => "There are not any groups of user to sync"}, ret)
  end

end
