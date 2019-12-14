require "test_helper"

class ModAdapTest < Minitest::Test
  #def test_that_it_has_a_version_number
  #  refute_nil ::ModAdap::VERSION
  #end

  def test_add_user_should_failed_if_ldap_add_was_failed
    # get_operation_result will returns...
    #   if success:
    #     #<OpenStruct extended_response=nil, code=0, error_message="", matched_dn="", message="Success">
    #   else if failed:
    #     #<OpenStruct extended_response=nil, code=65, error_message="no objectClass attribute", matched_dn="", message="Object Class Violation">

    mock_ldap                         = MiniTest::Mock.new
    mock_adap_create_ldap_attributes  = MiniTest::Mock.new
    mock_get_operation_result         = MiniTest::Mock.new

    # adap.create_ldap_attributes
    mock_adap_create_ldap_attributes.expect(
      :call,
      {:objectclass => ["top", "person"], :cn => "foo"},
      [{:objectclass => ["top", "person"], :cn => "foo"}]
    )

    # @ldap_client.add
    mock_ldap.expect(
      :add, true, [{
        :dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
        :attributes => {
          :objectclass => ["top", "person"],
          :cn => "foo"
        }
      }]
    )

    # @ldap_client.get_operation_result.code
    mock_get_operation_result.expect(:code, 1, [])
    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])
    # :ret => get_operation_result.code
    mock_get_operation_result.expect(:code, 1, [])
    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])
    # :message => get_operation_result.error_message
    mock_get_operation_result.expect(:error_message, "Some error", [])
    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])

    Net::LDAP.stub :new, mock_ldap do
      adap = Adap.new({
        :ad_host   => "localhost",
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_basedn => "dc=mysite,dc=example,dc=com"
      })

      adap.stub :create_ldap_attributes, mock_adap_create_ldap_attributes do
        ret = adap.add_user(
          "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
          {:objectclass => ["top", "person"], :cn => "foo"},
          "secret"
        )
        assert_equal({:code => 1, :message => "Failed to add a user uid=foo,ou=Users,dc=mysite,dc=example,dc=com in add_user() - Some error"}, ret)
        mock_ldap.verify
        mock_adap_create_ldap_attributes.verify
        mock_get_operation_result.verify
      end
    end
  end

  def test_add_user_should_failed_if_ldap_modify_was_failed
    mock_ldap                         = MiniTest::Mock.new
    mock_adap_create_ldap_attributes  = MiniTest::Mock.new
    mock_get_operation_result         = MiniTest::Mock.new

    # adap.create_ldap_attributes
    mock_adap_create_ldap_attributes.expect(
      :call,
      {:objectclass => ["top", "person"], :cn => "foo"},
      [{:objectclass => ["top", "person"], :cn => "foo"}]
    )

    # @ldap_client.add
    mock_ldap.expect(
      :add, true, [{
        :dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
        :attributes => {
          :objectclass => ["top", "person"],
          :cn => "foo"
        }
      }]
    )
    # @ldap_client.get_operation_result.code of @ldap_client.add
    mock_get_operation_result.expect(:code, 0, [])
    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])
    # @ldap_client.modify
    mock_ldap.expect(
      :modify, true, [{
        :dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
        :operations => [
          [:add, :userPassword, "secret"]
        ]
      }]
    )
    # @ldap_client.get_operation_result.code of @ldap_client.modify
    mock_get_operation_result.expect(:code, 1, [])
    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])
    # @ldap_client.get_operation_result.code of @ldap_client.modify
    mock_get_operation_result.expect(:code, 1, [])
    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])
    # @ldap_client.get_operation_result.code of @ldap_client.modify
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

      adap.stub :create_ldap_attributes, mock_adap_create_ldap_attributes do
        ret = adap.add_user(
          "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
          {:objectclass => ["top", "person"], :cn => "foo"},
          "secret"
        )
        assert_equal({:code => 1, :message => "Failed to modify a user uid=foo,ou=Users,dc=mysite,dc=example,dc=com in add_user() - Some error"}, ret)
        mock_ldap.verify
        mock_adap_create_ldap_attributes.verify
        mock_get_operation_result.verify
      end
    end
  end

  def test_add_user_should_success
    mock_ldap                         = MiniTest::Mock.new
    mock_adap_create_ldap_attributes  = MiniTest::Mock.new
    mock_get_operation_result         = MiniTest::Mock.new

    # adap.create_ldap_attributes
    mock_adap_create_ldap_attributes.expect(
      :call,
      {:objectclass => ["top", "person"], :cn => "foo"},
      [{:objectclass => ["top", "person"], :cn => "foo"}]
    )

    # @ldap_client.add
    mock_ldap.expect(
      :add, true, [{
        :dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
        :attributes => {
          :objectclass => ["top", "person"],
          :cn => "foo"
        }
      }]
    )
    # @ldap_client.get_operation_result.code of @ldap_client.add
    mock_get_operation_result.expect(:code, 0, [])
    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])
    # @ldap_client.modify
    mock_ldap.expect(
      :modify, true, [{
        :dn => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
        :operations => [
          [:add, :userPassword, "secret"]
        ]
      }]
    )
    # @ldap_client.get_operation_result.code of @ldap_client.modify
    mock_get_operation_result.expect(:code, 0, [])
    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])
    # @ldap_client.get_operation_result.code of @ldap_client.modify
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

      adap.stub :create_ldap_attributes, mock_adap_create_ldap_attributes do
        ret = adap.add_user(
          "uid=foo,ou=Users,dc=mysite,dc=example,dc=com",
          {:objectclass => ["top", "person"], :cn => "foo"},
          "secret"
        )
        assert_equal({:code => 0, :message => nil}, ret)
        mock_ldap.verify
        mock_adap_create_ldap_attributes.verify
        mock_get_operation_result.verify
      end
    end
  end
end
