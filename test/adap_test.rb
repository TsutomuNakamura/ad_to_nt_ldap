require "test_helper"

class ModAdapTest < Minitest::Test
  def test_raise_error_if_params_is_nil
    exception = assert_raises RuntimeError do
      Adap.new(nil)
    end
    assert_equal(exception.message, "Initialize Adap was failed. params must not be nil")
  end

  def test_raise_error_if_params_does_not_have_ad_host
    exception = assert_raises RuntimeError do
      Adap.new({
        #:ad_host => "localhost",
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :nt_host   => "ldap_server",
        :nt_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :nt_basedn => "dc=mysite,dc=example,dc=com"
      })
    end
    assert_equal(exception.message, 'Adap requires keys in params ":ad_host", ":ad_binddn", ":ad_basedn", ":ldap_host", ":ldap_binddn", ":ldap_basedn"')
  end

  def test_raise_error_if_params_does_not_have_ad_binddn
    exception = assert_raises RuntimeError do
      Adap.new({
        :ad_host => "localhost",
        #:ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :nt_host   => "ldap_server",
        :nt_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :nt_basedn => "dc=mysite,dc=example,dc=com"
      })
    end
    assert_equal(exception.message, 'Adap requires keys in params ":ad_host", ":ad_binddn", ":ad_basedn", ":ldap_host", ":ldap_binddn", ":ldap_basedn"')
  end

  def test_raise_error_if_params_does_not_have_ad_basedn
    exception = assert_raises RuntimeError do
      Adap.new({
        :ad_host => "localhost",
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        #:ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :nt_host   => "ldap_server",
        :nt_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :nt_basedn => "dc=mysite,dc=example,dc=com"
      })
    end
    assert_equal(exception.message, 'Adap requires keys in params ":ad_host", ":ad_binddn", ":ad_basedn", ":ldap_host", ":ldap_binddn", ":ldap_basedn"')
  end

  def test_raise_error_if_params_does_not_have_ad_host
    exception = assert_raises RuntimeError do
      Adap.new({
        :ad_host => "localhost",
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        #:nt_host   => "ldap_server",
        :nt_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :nt_basedn => "dc=mysite,dc=example,dc=com"
      })
    end
    assert_equal(exception.message, 'Adap requires keys in params ":ad_host", ":ad_binddn", ":ad_basedn", ":ldap_host", ":ldap_binddn", ":ldap_basedn"')
  end

  def test_raise_error_if_params_does_not_have_ad_binddn
    exception = assert_raises RuntimeError do
      Adap.new({
        :ad_host => "localhost",
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :nt_host   => "ldap_server",
        #:nt_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :nt_basedn => "dc=mysite,dc=example,dc=com"
      })
    end
    assert_equal(exception.message, 'Adap requires keys in params ":ad_host", ":ad_binddn", ":ad_basedn", ":ldap_host", ":ldap_binddn", ":ldap_basedn"')
  end

  def test_raise_error_if_params_does_not_have_ad_basedn
    exception = assert_raises RuntimeError do
      Adap.new({
        :ad_host => "localhost",
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :nt_host   => "ldap_server",
        :nt_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        #:nt_basedn => "dc=mysite,dc=example,dc=com"
      })
    end
    assert_equal(exception.message, 'Adap requires keys in params ":ad_host", ":ad_binddn", ":ad_basedn", ":ldap_host", ":ldap_binddn", ":ldap_basedn"')
  end

  def test_adap_should_be_able_to_set_ldap_suffix_ou
    r = get_general_adap_instance({ :ad_binddn => "DC=foooo,DC=example,DC=com" })
    assert_equal("DC=foooo,DC=example,DC=com", r.instance_variable_get(:@ad_binddn))
  end

  def test_adap_should_be_able_to_set_ldap_suffix_ou
    r = get_general_adap_instance({ :ldap_suffix_ou => "ou=Foo,ou=Users" })
    assert_equal("ou=Foo,ou=Users", r.instance_variable_get(:@ldap_suffix_ou))
  end
end
