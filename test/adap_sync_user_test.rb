require "test_helper"

class ModAdapTest < Minitest::Test
  #def test_that_it_has_a_version_number
  #  refute_nil ::ModAdap::VERSION
  #end

#  def test_sync_user_should_failed_if_ldap_modify_was_failed
#    mock_ldap                           = MiniTest::Mock.new
#    mock_get_operation_result           = MiniTest::Mock.new
#    
#    mock_get_ad_dn                      = MiniTest::Mock.new
#    mock_get_ldap_dn                    = MiniTest::Mock.new
#
#    # get_ad_dn()
#    mock_get_ad_dn.expect(:call, "CN=foo,CN=Users,DC=mysite,DC=example,DC=com", ["foo"])
#    mock_get_ldap_dn.expect(:call, "uid=foo,ou=Users,dc=mysite,dc=example,dc=com", ["foo"])
#
#    # @ad_client.search()
#
#    mock_ldap.expect(:search, , {:objectclass => ["top", "person"], :cn => "foo"})
#
#    # @ad_client.get_operation_result.code
#    mock_get_operation_result.expect(:code, 1, [])
#    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])
#    # @ad_client.get_operation_result.code
#    mock_get_operation_result.expect(:code, 1, [])
#    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])
#    # @ldap_client.get_operation_result.error_message of @ldap_client.delete
#    mock_get_operation_result.expect(:error_message, "Some error", [])
#    mock_ldap.expect(:get_operation_result, mock_get_operation_result, [])
#
#    Net::LDAP.stub :new, mock_ldap do
#      adap = Adap.new({
#        :ad_host => "localhost",
#        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
#        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
#        :ldap_host   => "ldap_server",
#        :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
#        :ldap_basedn => "dc=mysite,dc=example,dc=com"
#      })
#
#      adap.stub :get_ad_dn, mock_get_ad_dn do
#        adap.stub :get_ldap_dn, mock_get_ldap_dn do
#          ret = adap.sync_user("foo")
#          assert_equal({:code => 1, :message => "Failed to get a user CN=foo,CN=Users,DC=mysite,DC=example,DC=com from AD - Some error"})
#          mock_ldap.verify
#          mock_get_operation_result.verify
#          mock_get_ad_dn.verify
#          mock_get_ldap_dn.verify
#        end
#      end
#    end
#
#  end


  def test_sync_user_should_failed_if_ldap_modify_was_failed
    mock_ldap                           = mock()
    mock_get_operation_result           = mock()

    # @ad_client.search()
    mock_ldap.expects(:search)
      .with({:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com"})
      .yields({:objectclass => ["top", "person"], :cn => "foo"})

    # @ad_client.get_operation_result.code
    mock_get_operation_result.expects(:code).returns(1)
    mock_ldap.expects(:get_operation_result).returns(mock_get_operation_result)
    # @ad_client.get_operation_result.code
    mock_get_operation_result.expects(:code).returns(1)
    mock_ldap.expects(:get_operation_result).returns(mock_get_operation_result)
    # @ldap_client.get_operation_result.error_message of @ldap_client.delete
    mock_get_operation_result.expects(:error_message).returns("Some error")
    mock_ldap.expects(:get_operation_result).returns(mock_get_operation_result)

    Net::LDAP.stub :new, mock_ldap do
      adap = Adap.new({
        :ad_host => "localhost",
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_basedn => "dc=mysite,dc=example,dc=com"
      })
      adap.expects(:get_ad_dn).returns("CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
      adap.expects(:get_ldap_dn).returns("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")

      ret = adap.sync_user("foo")
      assert_equal({:code => 1, :message => "Failed to get a user CN=foo,CN=Users,DC=mysite,DC=example,DC=com from AD - Some error"}, ret)
      #1.times { mock_ldap.expects(:search).with({:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com"}) }
    end

  end

end
