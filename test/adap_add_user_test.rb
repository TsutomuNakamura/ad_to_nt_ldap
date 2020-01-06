require "test_helper"

class ModAdapTest < Minitest::Test
  def test_add_user_should_failed_if_ldap_add_was_failed
    # get_operation_result will returns...
    #   if success:
    #     #<OpenStruct extended_response=nil, code=0, error_message="", matched_dn="", message="Success">
    #   else if failed:
    #     #<OpenStruct extended_response=nil, code=65, error_message="no objectClass attribute", matched_dn="", message="Object Class Violation">

    mock_get_operation_result         = mock()
    mock                              = mock_ad_and_ldap_connections()

    # @ldap_client.add
    mock[:ldap_client].expects(:add)
      .with({
        :dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
        :attributes => {
          :objectclass => ["top", "person"],
          :cn => "foo"
        }
      }).returns(true)

    # @ldap_client.get_operation_result.code
    mock_get_operation_result.expects(:code).returns(1, 1).times(2)
    mock_get_operation_result.expects(:error_message).returns("Some error")
    mock[:ldap_client].expects(:get_operation_result).returns(mock_get_operation_result).times(3)

    adap = Adap.new({
      :ad_host   => "localhost",
      :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password => "ad_secret",
      :ldap_host   => "ldap_server",
      :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_basedn => "dc=mysite,dc=example,dc=com",
      :ldap_password => "ldap_secret"
    })
    adap.expects(:create_ldap_attributes)
      .with({:objectclass => ["top", "person"], :cn => "foo"})
      .returns({:objectclass => ["top", "person"], :cn => "foo"})

    ret = adap.add_user(
      "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
      {:objectclass => ["top", "person"], :cn => "foo"},
      "secret"
    )

    assert_equal({:code => 1, :message => "Failed to add a user uid=foo,ou=Users,dc=mysite,dc=example,dc=com in add_user() - Some error"}, ret)
  end

  def test_add_user_should_failed_if_ldap_modify_was_failed
    mock_ad_client                    = mock()
    mock_ldap_client                  = mock()
    mock_ldap_get_operation_result    = mock()

    Adap.expects(:get_ad_client_instance)
      .with("localhost", 389, { :method => :simple, :username => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com", :password => "ad_secret" })
      .returns(mock_ad_client)

    Adap.expects(:get_ldap_client_instance)
      .with("ldap_server", 389, { :method => :simple, :username => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com", :password => "ldap_secret" })
      .returns(mock_ldap_client)

    # @ldap_client.add
    mock_ldap_client.expects(:add)
      .with({
        :dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
        :attributes => {
          :objectclass => ["top", "person"],
          :cn => "foo"
        }
      })
      .returns(true)

    # @ldap_client.modify
    mock_ldap_client.expects(:modify)
      .with({
        :dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
        :operations => [
          [:add, :userPassword, "secret"]
        ]
      })
      .returns(true)

    # @ldap_client.get_operation_result.code of @ldap_client.modify
    mock_ldap_get_operation_result.expects(:code).returns(0, 1, 1).times(3)
    mock_ldap_get_operation_result.expects(:error_message).returns("Some error")
    mock_ldap_client.expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(4)

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

    adap.expects(:create_ldap_attributes)
      .with({:objectclass => ["top", "person"], :cn => "foo"})
      .returns({:objectclass => ["top", "person"], :cn => "foo"})

    ret = adap.add_user(
      "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
      {:objectclass => ["top", "person"], :cn => "foo"},
      "secret"
    )
    assert_equal({:code => 1, :message => "Failed to modify a user uid=foo,ou=Users,dc=mysite,dc=example,dc=com in add_user() - Some error"}, ret)
  end

  def test_add_user_should_success
    mock_ad_client                    = mock()
    mock_ldap_client                  = mock()
    mock_ldap_get_operation_result    = mock()

    Adap.expects(:get_ad_client_instance)
      .with("localhost", 389, { :method => :simple, :username => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com", :password => "ad_secret" })
      .returns(mock_ad_client)

    Adap.expects(:get_ldap_client_instance)
      .with("ldap_server", 389, { :method => :simple, :username => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com", :password => "ldap_secret" })
      .returns(mock_ldap_client)

    # @ldap_client.add
    mock_ldap_client.expects(:add)
      .with({
        :dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
        :attributes => {
          :objectclass => ["top", "person"],
          :cn => "foo"
        }
      })
      .returns(true)

    # @ldap_client.modify
    mock_ldap_client.expects(:modify)
      .with({
        :dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
        :operations => [
          [:add, :userPassword, "secret"]
        ]
      })
      .returns(true)

    # @ldap_client.get_operation_result.code of @ldap_client.modify
    mock_ldap_get_operation_result.expects(:code).returns(0, 0, 0).times(3)
    mock_ldap_client.expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(3)

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
    adap.expects(:create_ldap_attributes)
      .with({:objectclass => ["top", "person"], :cn => "foo"})
      .returns({:objectclass => ["top", "person"], :cn => "foo"})

    ret = adap.add_user(
      "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
      {:objectclass => ["top", "person"], :cn => "foo"},
      "secret"
    )
    assert_equal({:code => 0, :operation => :add_user, :message => nil}, ret)
  end
end
