
require "test_helper"

class ModAdapTest < Minitest::Test
  #def test_that_it_has_a_version_number
  #  refute_nil ::ModAdap::VERSION
  #end

  def test_delete_user_should_failed_if_ldap_delete_was_failed
    mock_ldap                           = MiniTest::Mock.new
    mock_get_operation_result           = MiniTest::Mock.new

    # @ldap_client.delete
    mock_ldap.expect(
      :delete, true, [{:dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com"}]
    )

    # @ldap_client.get_operation_result.code of @ldap_client.delete
    mock_get_operation_result.expect(:code, 1, [])
    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])

    # @ldap_client.get_operation_result.code of @ldap_client.delete
    mock_get_operation_result.expect(:code, 1, [])
    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])

    # @ldap_client.get_operation_result.error_message of @ldap_client.delete
    mock_get_operation_result.expect(:error_message, "Some error", [])
    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])

    Net::LDAP.stub :new, mock_ldap do
      adap = Adap.new({
        :ad_host => "localhost",
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_basedn => "dc=mysite,dc=example,dc=com"
      })

      ret = adap.delete_user("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
      assert_equal({:code => 1, :message => "Failed to delete a user uid=foo,ou=Users,dc=mysite,dc=example,dc=com in delete_user() - Some error"}, ret)
      mock_ldap.verify
      mock_get_operation_result.verify
    end
  end

  def test_delete_user_should_success
    mock_ldap                           = MiniTest::Mock.new
    mock_get_operation_result           = MiniTest::Mock.new

    # @ldap_client.delete
    mock_ldap.expect(
      :delete, true, [{:dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com"}]
    )

    # @ldap_client.get_operation_result.code of @ldap_client.delete
    mock_get_operation_result.expect(:code, 0, [])
    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])
    # @ldap_client.get_operation_result.code of @ldap_client.delete
    mock_get_operation_result.expect(:code, 0, [])
    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])

    Net::LDAP.stub :new, mock_ldap do
      adap = Adap.new({
        :ad_host => "localhost",
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_basedn => "dc=mysite,dc=example,dc=com"
      })

      ret = adap.delete_user("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
      assert_equal({:code => 0, :message => nil}, ret)
      mock_ldap.verify
      mock_get_operation_result.verify
    end
  end
end
