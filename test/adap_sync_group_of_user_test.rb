require "test_helper"

class ModAdapTest < Minitest::Test
#  def test_sync_group_of_user_should_call_ldap_client_search_without_gidfilter_if_parameter_of_gid_is_nil
#    mock                            = mock_ad_and_ldap_connections()
#    mock_ad_get_operation_result  = mock()
#    mock_ldap_get_operation_result  = mock()
#
#    Net::LDAP::Filter.expects(:construct).with(
#      "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com))"  # Tset
#    ).returns("(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com))")
#
#    # @ldap_client.modify
#    mock[:ad_client].expects(:search).with({
#      :base => "DC=mysite,DC=example,DC=com",
#      :filter => "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com))"
#    }).yields({:name => "Domain Users"})
#
#    mock_ad_get_operation_result.expects(:code).returns(0)
#    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)
#
#    Net::LDAP::Filter.expects(:construct)
#      .with("(memberUid=foo)")
#      .returns("(memberUid=foo)")
#    mock[:ldap_client].expects(:search).with({
#      :base => "ou=Users,dc=mysite,dc=example,dc=com", :filter => "(memberUid=foo)"
#    }).yields({:cn => "Domain Users"})
#
#    mock_ldap_get_operation_result.expects(:code).returns(0)
#    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)
#
#    # Testing from here
#    adap = Adap.new({
#      :ad_host        => "localhost",
#      :ad_binddn      => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
#      :ad_basedn      => "DC=mysite,DC=example,DC=com",
#      :ad_password    => "ad_secret",
#      :ldap_host      => "ldap_server",
#      :ldap_binddn    => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
#      :ldap_basedn    => "dc=mysite,dc=example,dc=com",
#      :ldap_password  => "ldap_secret"
#    })
#    adap.expects(:create_sync_group_of_user_operation)
#      .with({"Domain Users" => nil}, {"Domain Users" => nil}, "foo")
#      .returns({})
#
#    ret = adap.sync_group_of_user("foo", nil)
#    assert_equal({:code => 0, :operations => [:modify_group_of_user], :message => "There are not any groups of user to sync"}, ret)
#  end
#
#  def test_sync_group_of_user_should_call_ldap_client_search_with_gidfilter_if_parameter_of_gid_is_not_nil
#    mock                            = mock_ad_and_ldap_connections()
#    mock_ad_get_operation_result  = mock()
#    mock_ldap_get_operation_result  = mock()
#
#    Net::LDAP::Filter.expects(:construct).with(
#      "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))"
#    ).returns("(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))")
#
#    # @ldap_client.modify
#    mock[:ad_client].expects(:search).with({
#      :base => "DC=mysite,DC=example,DC=com",
#      :filter => "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))"
#    }).yields({:name => "Domain Users"})
#
#    mock_ad_get_operation_result.expects(:code).returns(0)
#    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)
#
#    Net::LDAP::Filter.expects(:construct)
#      .with("(memberUid=foo)")
#      .returns("(memberUid=foo)")
#    mock[:ldap_client].expects(:search).with({
#      :base => "ou=Users,dc=mysite,dc=example,dc=com", :filter => "(memberUid=foo)"
#    }).yields({:cn => "Domain Users"})
#
#    mock_ldap_get_operation_result.expects(:code).returns(0)
#    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)
#
#    # Testing from here
#    adap = Adap.new({
#      :ad_host        => "localhost",
#      :ad_binddn      => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
#      :ad_basedn      => "DC=mysite,DC=example,DC=com",
#      :ad_password    => "ad_secret",
#      :ldap_host      => "ldap_server",
#      :ldap_binddn    => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
#      :ldap_basedn    => "dc=mysite,dc=example,dc=com",
#      :ldap_password  => "ldap_secret"
#    })
#    ret = adap.sync_group_of_user("foo", 513)
#    assert_equal({:code => 0, :operations => [:modify_group_of_user], :message => "There are not any groups of user to sync"}, ret)
#  end
#
#  def test_sync_group_of_user_should_return_error_if_ad_search_has_failed
#    mock                            = mock_ad_and_ldap_connections()
#    mock_ad_get_operation_result    = mock()
#    #mock_ldap_get_operation_result  = mock()
#
#    Net::LDAP::Filter.expects(:construct).with(
#      "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))"
#    ).returns("(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))")
#
#    # @ldap_client.modify
#    mock[:ad_client].expects(:search).with({
#      :base => "DC=mysite,DC=example,DC=com",
#      :filter => "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))"
#    }).yields({:name => "Domain Users"})
#
#    mock_ad_get_operation_result.expects(:code).returns(1)    # Test
#    mock_ad_get_operation_result.expects(:error_message).returns("Some error")
#    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result).times(2)
#
#    # Testing from here
#    adap = Adap.new({
#      :ad_host        => "localhost",
#      :ad_binddn      => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
#      :ad_basedn      => "DC=mysite,DC=example,DC=com",
#      :ad_password    => "ad_secret",
#      :ldap_host      => "ldap_server",
#      :ldap_binddn    => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
#      :ldap_basedn    => "dc=mysite,dc=example,dc=com",
#      :ldap_password  => "ldap_secret"
#    })
#    ret = adap.sync_group_of_user("foo", 513)
#    assert_equal({:code => 1, :operations => [:search_groups_from_ad], :message => "Failed to get groups of a user foo from AD to sync them. Some error"}, ret)
#  end
#
#  def test_sync_group_of_user_should_return_error_if_ldap_search_has_failed
#    mock                            = mock_ad_and_ldap_connections()
#    mock_ad_get_operation_result    = mock()
#    mock_ldap_get_operation_result  = mock()
#
#    Net::LDAP::Filter.expects(:construct).with(
#      "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))"
#    ).returns("(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))")
#
#    # @ldap_client.modify
#    mock[:ad_client].expects(:search).with({
#      :base => "DC=mysite,DC=example,DC=com",
#      :filter => "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))"
#    }).yields({:name => "Domain Users"})
#
#    mock_ad_get_operation_result.expects(:code).returns(0)    # Test
#    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)
#
#    Net::LDAP::Filter.expects(:construct)
#      .with("(memberUid=foo)")
#      .returns("(memberUid=foo)")
#    mock[:ldap_client].expects(:search).with({
#      :base => "ou=Users,dc=mysite,dc=example,dc=com", :filter => "(memberUid=foo)"
#    }).yields({:cn => "Domain Users"})
#    mock_ldap_get_operation_result.expects(:code).returns(1)
#    mock_ldap_get_operation_result.expects(:error_message).returns("Some error")
#    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(2)
#
#    # Testing from here
#    adap = Adap.new({
#      :ad_host        => "localhost",
#      :ad_binddn      => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
#      :ad_basedn      => "DC=mysite,DC=example,DC=com",
#      :ad_password    => "ad_secret",
#      :ldap_host      => "ldap_server",
#      :ldap_binddn    => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
#      :ldap_basedn    => "dc=mysite,dc=example,dc=com",
#      :ldap_password  => "ldap_secret"
#    })
#    ret = adap.sync_group_of_user("foo", 513)
#    assert_equal({:code => 1, :operations => [:search_groups_from_ldap], :message => "Failed to get groups of a user foo from LDAP to sync them. Some error"}, ret)
#  end

  def test_sync_group_of_user_should_create_add_operation_if_ad_has_new_groups
    mock                            = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result    = mock()
    mock_ldap_get_operation_result  = mock()

    Net::LDAP::Filter.expects(:construct).with(
      "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))"
    ).returns("(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))")

    # @ldap_client.modify
    mock[:ad_client].expects(:search).with({
      :base => "DC=mysite,DC=example,DC=com",
      :filter => "(&(objectCategory=CN=Group,CN=Schema,CN=Configuration,DC=mysite,DC=example,DC=com)(|(member=CN=foo,CN=Users,DC=mysite,DC=example,DC=com)(gidNumber=513)))"
    }).multiple_yields({:name => "Domain Users"}, {:name => "Domain Admins"})

    mock_ad_get_operation_result.expects(:code).returns(0)    # Test
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    Net::LDAP::Filter.expects(:construct)
      .with("(memberUid=foo)")
      .returns("(memberUid=foo)")
    mock[:ldap_client].expects(:search).with({
      :base => "ou=Users,dc=mysite,dc=example,dc=com", :filter => "(memberUid=foo)"
    }).yields({:cn => "Domain Users"})
    mock_ldap_get_operation_result.expects(:code).returns(0, 1).times(2)
    mock_ldap_get_operation_result.expects(:error_message).returns("Some error")
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(3)

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
    adap.expects(:create_sync_group_of_user_operation)
      .with({"Domain Users" => nil, "Domain Admins" => nil}, {"Domain Users" => nil}, "foo")
      .returns({
        "cn=Domain Admins,cn=Groups,dc=mysite,dc=example,dc=com" => [
          [:add, :memberuid, "foo"]
        ]
      })
    mock[:ldap_client].expects(:modify)
      .with({:dn => "cn=Domain Admins,cn=Groups,dc=mysite,dc=example,dc=com", :operations => [[:add, :memberuid, "foo"]]})

    ret = adap.sync_group_of_user("foo", 513)
    assert_equal({
      :code => 1,
      :operations => [:modify_group_of_user],
      :message => "Failed to modify group \"cn=Domain Admins,cn=Groups,dc=mysite,dc=example,dc=com\" of user foo. Some error"}, ret)
  end
end
