require "test_helper"

class ModAdapTest < Minitest::Test
  def test_get_password_should_return_error_if_getting_raw_password_returns_empty_string
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
    adap.expects(:get_raw_password).with("foo", "virtualCryptSHA512").returns("")

    exception = assert_raises RuntimeError do
      result = adap.get_password("foo")
    end
    assert_equal(
      exception.message,
      'Failed to get password of foo from AD. Did you enabled AD password option virtualCryptSHA512 and/or virtualCryptSHA256?'
    )
  end

  def test_get_password_should_return_error_if_getting_raw_password_returns_nil
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
    adap.expects(:get_raw_password).with("foo", "virtualCryptSHA512").returns(nil)

    exception = assert_raises RuntimeError do
      result = adap.get_password("foo")
    end
    assert_equal(
      exception.message,
      'Failed to get password of foo from AD. Did you enabled AD password option virtualCryptSHA512 and/or virtualCryptSHA256?'
    )
  end

end
