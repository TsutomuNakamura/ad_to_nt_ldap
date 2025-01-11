require "test_helper"

class ModAdapTest < Minitest::Test

  def test_adap_new_success
    adap = Adap.new({
        :ad_host            => "localhost",
        :ad_bind_dn         => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_user_base_dn    => "CN=Users,DC=mysite,DC=example,DC=com",
        :ad_group_base_dn   => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host          => "ldap_server",
        :ldap_bind_dn       => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_user_base_dn  => "ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_group_base_dn => "ou=Groups,dc=mysite,dc=example,dc=com"
      })
    assert(adap.is_a?(Adap))
  end

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
        :ad_bind_dn         => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_user_base_dn    => "CN=Users,DC=mysite,DC=example,DC=com",
        :ad_group_base_dn   => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host          => "ldap_server",
        :ldap_bind_dn       => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_user_base_dn  => "ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_group_base_dn => "ou=Groups,dc=mysite,dc=example,dc=com"
      })
    end
    assert_equal(exception.message, 'Adap requires keys in params ":ad_host", ":ad_bind_dn", ":ad_user_base_dn", ":ad_group_base_dn", ":ldap_host", ":ldap_bind_dn", ":ldap_user_base_dn", ":ldap_group_base_dn"')
  end

  def test_raise_error_if_params_does_not_have_ad_bind_dn
    exception = assert_raises RuntimeError do
      Adap.new({
        :ad_host => "localhost",
        #:ad_bind_dn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_user_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ad_group_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_bind_dn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_user_base_dn => "ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_group_base_dn => "ou=Groups,dc=mysite,dc=example,dc=com"
      })
    end
    assert_equal(exception.message, 'Adap requires keys in params ":ad_host", ":ad_bind_dn", ":ad_user_base_dn", ":ad_group_base_dn", ":ldap_host", ":ldap_bind_dn", ":ldap_user_base_dn", ":ldap_group_base_dn"')
  end

  def test_raise_error_if_params_does_not_have_ad_user_base_dn
    exception = assert_raises RuntimeError do
      Adap.new({
        :ad_host => "localhost",
        :ad_bind_dn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        #:ad_user_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ad_group_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_bind_dn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_user_base_dn => "ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_group_base_dn => "ou=Groups,dc=mysite,dc=example,dc=com"
      })
    end
    assert_equal(exception.message, 'Adap requires keys in params ":ad_host", ":ad_bind_dn", ":ad_user_base_dn", ":ad_group_base_dn", ":ldap_host", ":ldap_bind_dn", ":ldap_user_base_dn", ":ldap_group_base_dn"')
  end

  def test_raise_error_if_params_does_not_have_ad_group_base_dn
    exception = assert_raises RuntimeError do
      Adap.new({
        :ad_host => "localhost",
        :ad_bind_dn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_user_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        #:ad_group_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_bind_dn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_user_base_dn => "ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_group_base_dn => "ou=Groups,dc=mysite,dc=example,dc=com"
      })
    end
    assert_equal(exception.message, 'Adap requires keys in params ":ad_host", ":ad_bind_dn", ":ad_user_base_dn", ":ad_group_base_dn", ":ldap_host", ":ldap_bind_dn", ":ldap_user_base_dn", ":ldap_group_base_dn"')
  end

  def test_raise_error_if_params_does_not_have_ldap_host
    exception = assert_raises RuntimeError do
      Adap.new({
        :ad_host => "localhost",
        :ad_bind_dn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_user_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ad_group_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        #:ldap_host   => "ldap_server",
        :ldap_bind_dn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_user_base_dn => "ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_group_base_dn => "ou=Groups,dc=mysite,dc=example,dc=com"
      })
    end
    assert_equal(exception.message, 'Adap requires keys in params ":ad_host", ":ad_bind_dn", ":ad_user_base_dn", ":ad_group_base_dn", ":ldap_host", ":ldap_bind_dn", ":ldap_user_base_dn", ":ldap_group_base_dn"')
  end

  def test_raise_error_if_params_does_not_have_ldap_bind_dn
    exception = assert_raises RuntimeError do
      Adap.new({
        :ad_host => "localhost",
        :ad_bind_dn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_user_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ad_group_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        #:ldap_bind_dn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_user_base_dn => "ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_group_base_dn => "ou=Groups,dc=mysite,dc=example,dc=com"
      })
    end
    assert_equal(exception.message, 'Adap requires keys in params ":ad_host", ":ad_bind_dn", ":ad_user_base_dn", ":ad_group_base_dn", ":ldap_host", ":ldap_bind_dn", ":ldap_user_base_dn", ":ldap_group_base_dn"')
  end

  def test_raise_error_if_params_does_not_have_ldap_user_basedn
    exception = assert_raises RuntimeError do
      Adap.new({
        :ad_host => "localhost",
        :ad_bind_dn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_user_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ad_group_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_bind_dn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        #:ldap_user_base_dn => "ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_group_base_dn => "ou=Groups,dc=mysite,dc=example,dc=com"
      })
    end
    assert_equal(exception.message, 'Adap requires keys in params ":ad_host", ":ad_bind_dn", ":ad_user_base_dn", ":ad_group_base_dn", ":ldap_host", ":ldap_bind_dn", ":ldap_user_base_dn", ":ldap_group_base_dn"')
  end

  def test_raise_error_if_params_does_not_have_ldap_group_base_dn
    exception = assert_raises RuntimeError do
      Adap.new({
        :ad_host => "localhost",
        :ad_bind_dn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_user_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ad_group_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_bind_dn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_user_base_dn => "ou=Users,dc=mysite,dc=example,dc=com",
        #:ldap_group_base_dn => "ou=Groups,dc=mysite,dc=example,dc=com"
      })
    end
    assert_equal(exception.message, 'Adap requires keys in params ":ad_host", ":ad_bind_dn", ":ad_user_base_dn", ":ad_group_base_dn", ":ldap_host", ":ldap_bind_dn", ":ldap_user_base_dn", ":ldap_group_base_dn"')
  end

  def test_raise_error_if_unsupported_algorithm_was_specified_as_password_hash_algorithm
    exception = assert_raises RuntimeError do
      Adap.new({
        :ad_host => "localhost",
        :ad_bind_dn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_user_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ad_group_base_dn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_bind_dn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_user_base_dn => "ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_group_base_dn => "ou=Groups,dc=mysite,dc=example,dc=com",
        :password_hash_algorithm => :md4
      })
    end
    assert_equal(
      'This program only supports :md5, :sha, :ssha(default), :virtual_crypt_sha256 and :virtual_crypt_sha512 as :password_hash_algorithm. An algorithm you chose :md4 was unsupported.',
      exception.message
    )
  end

  def test_adap_should_be_able_to_set_ad_suffix_dc
    r = get_general_adap_instance({ :ad_bind_dn => "DC=foooo,DC=example,DC=com" })
    assert_equal("DC=foooo,DC=example,DC=com", r.instance_variable_get(:@ad_bind_dn))
  end
end
