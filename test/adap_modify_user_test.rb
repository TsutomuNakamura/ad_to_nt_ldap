require "test_helper"

class ModAdapTest < Minitest::Test
  def test_modify_user_should_failed_if_ldap_modify_was_failed
    mock_ad_client                  = mock()
    mock_ldap_client                = mock()
    #mock_ad_get_operation_result    = mock()
    mock_ldap_get_operation_result  = mock()

    Adap.expects(:get_ad_client_instance)
      .with("localhost", 389, { :method => :simple, :username => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com", :password => "ad_secret" })
      .returns(mock_ad_client)

    Adap.expects(:get_ldap_client_instance)
      .with("ldap_server", 389, { :method => :simple, :username => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com", :password => "ldap_secret" })
      .returns(mock_ldap_client)

    # @ldap_client.modify
    mock_ldap_client.expects(:modify).with({
      :dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
      :operations => [
        [:replace, :cn, "cn_ad"]
      ]
    }).returns(true)

    # @ldap_client.get_operation_result.code of @ldap_client.modify
    mock_ldap_get_operation_result.expects(:code).returns(1, 1).times(2)
    mock_ldap_get_operation_result.expects(:error_message).returns("Some error")
    mock_ldap_client.expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(3)

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
    assert_equal({:code => 1, :message => "Failed to modify a user uid=foo,ou=Users,dc=mysite,dc=example,dc=com in modify_user() - Some error"}, ret)
  end

  def test_modify_user_should_success
    mock_ad_client                  = mock()
    mock_ldap_client                = mock()
    #mock_ad_get_operation_result    = mock()
    mock_ldap_get_operation_result  = mock()

    Adap.expects(:get_ad_client_instance)
      .with("localhost", 389, { :method => :simple, :username => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com", :password => "ad_secret" })
      .returns(mock_ad_client)

    Adap.expects(:get_ldap_client_instance)
      .with("ldap_server", 389, { :method => :simple, :username => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com", :password => "ldap_secret" })
      .returns(mock_ldap_client)

    # @ldap_client.modify
    mock_ldap_client.expects(:modify).with({
      :dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
      :operations => [
        [:replace, :cn, "cn_ad"]
      ]
    }).returns(true)

    # @ldap_client.get_operation_result.code
    mock_ldap_get_operation_result.expects(:code).returns(0, 0).times(2)
    mock_ldap_client.expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(2)

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
    assert_equal({:code => 0, :message => nil}, ret)
  end

end
