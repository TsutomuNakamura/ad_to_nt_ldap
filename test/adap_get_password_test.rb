require "test_helper"

class ModAdapTest < Minitest::Test
  def test_get_password_should_return_empty_string_if_getting_raw_password_returns_empty_string
    mock_ad_and_ldap_connections()

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
    result = adap.get_password("foo")
    assert_equal(result, "")
  end

  def test_get_password_should_return_nil_if_getting_raw_password_returns_nil
    mock_ad_and_ldap_connections()

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
    result = adap.get_password("foo")
    assert_equal(result, nil)
  end

  def test_get_password_should_success_if_sha256_option_has_been_passed
    mock_ad_and_ldap_connections()

    adap = Adap.new({
      :ad_host => "localhost",
      :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password => "ad_secret",
      :ldap_host   => "ldap_server",
      :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_basedn => "dc=mysite,dc=example,dc=com",
      :ldap_password => "ldap_secret",
      :password_hash_algorithm => 'virtualCryptSHA256'
    })
    # get_raw_password should be called with a parameter 'virtualCryptSHA256'
    adap.expects(:get_raw_password).with("foo", "virtualCryptSHA256").returns("secret_sha256")

    result = adap.get_password("foo")
    assert_equal(result, 'secret_sha256')
  end

  def test_get_password_should_success
    mock_ad_and_ldap_connections()

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
    # get_raw_password should be called with a parameter 'virtualCryptSHA256'
    adap.expects(:get_raw_password).with("foo", "virtualCryptSHA512").returns("secret_sha512")

    result = adap.get_password("foo")
    assert_equal(result, 'secret_sha512')
  end

  def test_get_password_should_chomp_hashed_password
    mock_ad_and_ldap_connections()

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
    adap.expects(:get_raw_password).with("foo", "virtualCryptSHA512").returns("secret_sha512\n")
    result = adap.get_password("foo")
    assert_equal(result, 'secret_sha512')
  end
end
