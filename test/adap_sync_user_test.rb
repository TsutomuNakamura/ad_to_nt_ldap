require "test_helper"

class ModAdapTest < Minitest::Test

  def test_sync_user_should_failed_if_ldap_search_from_ad_was_failed
    mock_ad_client                      = mock()
    mock_ldap_client                    = mock()
    mock_ad_get_operation_result        = mock()
    mock_ldap_get_operation_result      = mock()

#    Adap.expects(:get_ad_client_instance)
#      .with(["localhost", 389, { :method => :simple, :username => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com", :password => "ad_secret" }])
#      .returns(mock_ad_client)

    Adap.expects(:get_ad_client_instance)
      .with("localhost", 389, { :method => :simple, :username => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com", :password => "ad_secret" })
      .returns(mock_ad_client)

    Adap.expects(:get_ldap_client_instance)
      .with("ldap_server", 389, { :method => :simple, :username => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com", :password => "ldap_secret" })
      .returns(mock_ldap_client)

    # @ad_client.search()
    mock_ad_client.expects(:search)
      .with({:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com"})
      .yields({:objectclass => ["top", "person"], :cn => "ad"})

#    mock_ldap_client.expects(:search)
#      .with({:base => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com"})
#      .yields({:objectclass => ["top", "person"], :cn => "ldap"})

    # @ad_client.get_operation_result.code
    mock_ad_get_operation_result.expects(:code).returns(1, 1).times(2)
    # @ldap_client.get_operation_result.error_message of @ldap_client.delete
    mock_ad_get_operation_result.expects(:error_message).returns("Some error")
    mock_ad_client.expects(:get_operation_result).returns(mock_ad_get_operation_result).times(3)

    # Testing from here
    adap = Adap.new({
      :ad_host        => "localhost",
      :ad_binddn      => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_basedn      => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password    => "ad_secret",
      :ldap_host      => "ldap_server",
      :ldap_binddn    => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_basedn    => "dc=mysite,dc=example,dc=com",
      :ldap_password  => "ldap_secret"
    })
    adap.expects(:get_ad_dn).returns("CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
    adap.expects(:get_ldap_dn).returns("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
    ret = adap.sync_user("foo")
    assert_equal({:code => 1, :message => "Failed to get a user CN=foo,CN=Users,DC=mysite,DC=example,DC=com from AD - Some error"}, ret)
  end

#  def test_sync_user_should_failed_if_ldap_search_from_ldap_was_failed
#    mock_ldap                           = mock()
#    mock_get_operation_result           = mock()
#
#    # @ad_client.search(:base => <AD>)
#    mock_ldap.expects(:search).returns({:objectclass => ["top", "person"], :cn => "foo"}).times(2)
#
#    # @ad_client.get_operation_result.code
#    mock_get_operation_result.expects(:code).returns(0, 1, 1).times(3)
#
#    # @ldap_client.get_operation_result.error_message of @ldap_client.delete
#    mock_get_operation_result.expects(:error_message).returns("Some error")
#    mock_ldap.expects(:get_operation_result).returns(mock_get_operation_result).times(4)
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
#      adap.expects(:get_ad_dn).returns("CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
#      adap.expects(:get_ldap_dn).returns("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
#
#      ret = adap.sync_user("foo")
#      assert_equal({:code => 1, :message => "Failed to get a user uid=foo,ou=Users,dc=mysite,dc=example,dc=com from LDAP - Some error"}, ret)
#    end
#  end
#
#  def test_sync_user_should_failed_if_ldap_search_from_ldap_was_failed
#    mock_ldap                           = mock()
#    mock_get_operation_result           = mock()
#
#    # @ad_client.search()
#    mock_ldap.expects(:search)
#      .with({:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com"})
#      .yields({:objectclass => ["top", "person"], :cn => "foo"})
#
#
#  end

end
