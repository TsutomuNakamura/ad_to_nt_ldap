require "test_helper"

class ModAdapTest < Minitest::Test
  def test_modify_user_should_failed_if_ldap_modify_was_failed
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    # @ldap_client.modify
    mock[:ldap_client].expects(:modify).with({
      :dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
      :operations => [
        [:replace, :cn, "cn_ad"]
      ]
    }).returns(true)

    # @ldap_client.get_operation_result.code of @ldap_client.modify
    mock_ldap_get_operation_result.expects(:code).returns(1)
    mock_ldap_get_operation_result.expects(:error_message).returns("Some error")
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(2)

    # Testing from here...
    adap = Adap.new({
      :ad_host => "localhost",
      :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password => "ad_secret",
      :ldap_host   => "ldap_server",
      :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_basedn => "dc=mysite,dc=example,dc=com",
      :ldap_password => "ldap_secret"
    })

    # adap.create_modify_operations in modify_user()
    adap.expects(:create_modify_operations).with(
      {:objectclass => ["top", "person"], :cn => "cn_ad"},
      {:objectclass => ["top", "person"], :cn => "cn_ldap"},
      "secret"
    ).returns([
      [:replace, :cn, "cn_ad"]
    ])

    ret = adap.modify_user(
      "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
      {:objectclass => ["top", "person"], :cn => "cn_ad"},
      {:objectclass => ["top", "person"], :cn => "cn_ldap"},
      "secret"
    )
    assert_equal({:code => 1, :operation => :modify_user, :message => "Failed to modify a user uid=foo,ou=Users,dc=mysite,dc=example,dc=com in modify_user() - Some error"}, ret)
  end

  def test_modify_user_should_success
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    # @ldap_client.modify
    mock[:ldap_client].expects(:modify).with({
      :dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
      :operations => [
        [:replace, :cn, "cn_ad"]
      ]
    }).returns(true)

    # @ldap_client.get_operation_result.code
    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    adap = Adap.new({
      :ad_host => "localhost",
      :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password => "ad_secret",
      :ldap_host   => "ldap_server",
      :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_basedn => "dc=mysite,dc=example,dc=com",
      :ldap_password => "ldap_secret"
    })

    adap.expects(:create_modify_operations).with(
      {:objectclass => ["top", "person"], :cn => "cn_ad"},
      {:objectclass => ["top", "person"], :cn => "cn_ldap"},
      "secret"
    ).returns([
      [:replace, :cn, "cn_ad"]
    ])

    ret = adap.modify_user(
      "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
      {:objectclass => ["top", "person"], :cn => "cn_ad"},
      {:objectclass => ["top", "person"], :cn => "cn_ldap"},
      "secret"
    )
    assert_equal({:code => 0, :operation => :modify_user, :message => nil}, ret)
  end
end
