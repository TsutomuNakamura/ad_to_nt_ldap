require "test_helper"

class ModAdapTest < Minitest::Test
  def test_get_password_should_failed_if_get_raw_password_returns_empty_string_with_algo_virtualcryptsha512
    mock_ad_and_ldap_connections()

    adap = Adap.new({
      :ad_host                  => "localhost",
      :ad_bind_dn               => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_base_dn          => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_base_dn         => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password              => "ad_secret",
      :ldap_host                => "ldap_server",
      :ldap_bind_dn             => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_base_dn        => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_base_dn       => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password            => "ldap_secret",
      :password_hash_algorithm  => :virtual_crypt_sha512
    })
    adap.expects(:get_raw_password_from_ad).with("foo", "virtualCryptSHA512").returns("")

    exception = assert_raises RuntimeError do
      adap.get_password_hash("foo", nil)
    end

    assert_equal(
      "Failed to get hashed password with algorithm :virtual_crypt_sha512 of user foo. Its result was nil. If you chose hash-algorithm :virtual_crypt_sha256 or :virtual_crypt_sha512, did you enabled AD to store passwords as virtualCryptSHA256 and/or virtualCryptSHA512 in your smb.conf? This program requires the configuration to get password from AD as virtualCryptSHA256 or virtualCryptSHA512.",
      exception.message
    )
  end

  def test_get_password_should_return_nil_if_getting_raw_password_returns_nil_with_algo_virtualcryptsha512
    mock_ad_and_ldap_connections()

    adap = Adap.new({
      :ad_host                  => "localhost",
      :ad_bind_dn               => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_base_dn          => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_base_dn         => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password              => "ad_secret",
      :ldap_host                => "ldap_server",
      :ldap_bind_dn             => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_base_dn        => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_base_dn       => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password            => "ldap_secret",
      :password_hash_algorithm  => :virtual_crypt_sha512
    })
    adap.expects(:get_raw_password_from_ad).with("foo", "virtualCryptSHA512").returns(nil)

    exception = assert_raises RuntimeError do
      adap.get_password_hash("foo", nil)
    end

    assert_equal(
      "Failed to get hashed password with algorithm :virtual_crypt_sha512 of user foo. Its result was nil. If you chose hash-algorithm :virtual_crypt_sha256 or :virtual_crypt_sha512, did you enabled AD to store passwords as virtualCryptSHA256 and/or virtualCryptSHA512 in your smb.conf? This program requires the configuration to get password from AD as virtualCryptSHA256 or virtualCryptSHA512.",
      exception.message
    )
  end

  def test_get_password_should_throw_an_exception_if_password_was_nil_with_algo_ssha
    mock_ad_and_ldap_connections()

    adap = Adap.new({
      :ad_host                      => "localhost",
      :ad_bind_dn                   => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_base_dn              => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_base_dn             => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password                  => "ad_secret",
      :ldap_host                    => "ldap_server",
      :ldap_bind_dn                 => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_base_dn            => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_base_dn           => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password                => "ldap_secret",
      #:password_hash_algorithm      => :virtual_crypt_sha512
    })

    exception = assert_raises RuntimeError do
      adap.get_password_hash("foo", nil)
    end

    assert_equal(
      "Password must not be nil when you chose the algorithm of password-hash is :md5 or :sha or :ssha. Pass password of foo please.",
      exception.message
    )
  end

  def test_get_password_should_success_with_algo_virtual_crypt_sha256
    mock_ad_and_ldap_connections()

    adap = Adap.new({
      :ad_host                  => "localhost",
      :ad_bind_dn               => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_base_dn          => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_base_dn         => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password              => "ad_secret",
      :ldap_host                => "ldap_server",
      :ldap_bind_dn             => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_base_dn        => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_base_dn       => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password            => "ldap_secret",
      :password_hash_algorithm  => :virtual_crypt_sha256
    })
    # get_raw_password_from_ad should be called with a parameter 'virtualCryptSHA256'
    adap.expects(:get_raw_password_from_ad).with("foo", "virtualCryptSHA256").returns("secret_sha256")

    result = adap.get_password_hash("foo", nil)
    assert_equal('secret_sha256', result)
  end

  def test_get_password_should_success_with_algo_virtual_crypt_sha512
    mock_ad_and_ldap_connections()

    adap = Adap.new({
      :ad_host                  => "localhost",
      :ad_bind_dn               => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_base_dn          => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_base_dn         => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password              => "ad_secret",
      :ldap_host                => "ldap_server",
      :ldap_bind_dn             => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_base_dn        => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_base_dn       => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password            => "ldap_secret",
      :password_hash_algorithm  => :virtual_crypt_sha512
    })
    # get_raw_password_from_ad should be called with a parameter 'virtualCryptSHA256'
    adap.expects(:get_raw_password_from_ad).with("foo", "virtualCryptSHA512").returns("secret_sha512")

    result = adap.get_password_hash("foo", nil)
    assert_equal('secret_sha512', result)
  end

  def test_get_password_should_success_with_algo_virtual_crypt_ssha
    mock_ad_and_ldap_connections()

    # Adap chose ssha hash algorithm by default
    adap = Adap.new({
      :ad_host                  => "localhost",
      :ad_bind_dn               => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_base_dn          => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_base_dn         => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password              => "ad_secret",
      :ldap_host                => "ldap_server",
      :ldap_bind_dn             => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_base_dn        => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_base_dn       => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password            => "ldap_secret",
      #:password_hash_algorithm  => :virtual_crypt_sha512
    })
    # get_raw_password_from_ad should be called with a parameter 'virtualCryptSHA256'
    #adap.expects(:create_hashed_password).with("secret").returns("secret_sha512")

    result = adap.get_password_hash("foo", "secret")
    assert_match(/^{SSHA}.+/, result)
  end

  def test_get_password_should_success_with_algo_virtual_crypt_md5
    mock_ad_and_ldap_connections()

    # Adap chose ssha hash algorithm by default
    adap = Adap.new({
      :ad_host                  => "localhost",
      :ad_bind_dn               => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_base_dn          => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_base_dn         => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password              => "ad_secret",
      :ldap_host                => "ldap_server",
      :ldap_bind_dn             => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_base_dn        => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_base_dn       => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password            => "ldap_secret",
      :password_hash_algorithm  => :md5
    })
    # get_raw_password_from_ad should be called with a parameter 'virtualCryptSHA256'
    #adap.expects(:create_hashed_password).with("secret").returns("secret_sha512")

    result = adap.get_password_hash("foo", "secret")
    assert_match(/^{MD5}.+/, result)
  end

  def test_get_password_should_success_with_algo_virtual_crypt_sha
    mock_ad_and_ldap_connections()

    # Adap chose ssha hash algorithm by default
    adap = Adap.new({
      :ad_host                  => "localhost",
      :ad_bind_dn               => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_base_dn          => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_base_dn         => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password              => "ad_secret",
      :ldap_host                => "ldap_server",
      :ldap_bind_dn             => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_base_dn        => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_base_dn       => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password            => "ldap_secret",
      :password_hash_algorithm  => :sha
    })
    # get_raw_password_from_ad should be called with a parameter 'virtualCryptSHA256'
    #adap.expects(:create_hashed_password).with("secret").returns("secret_sha512")

    result = adap.get_password_hash("foo", "secret")
    assert_match(/^{SHA}.+/, result)
  end

  def test_get_password_should_chomp_hashed_password
    mock_ad_and_ldap_connections()

    adap = Adap.new({
      :ad_host                  => "localhost",
      :ad_bind_dn               => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_base_dn          => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_base_dn         => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password              => "ad_secret",
      :ldap_host                => "ldap_server",
      :ldap_bind_dn             => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_base_dn        => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_base_dn       => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password            => "ldap_secret",
      :password_hash_algorithm  => :virtual_crypt_sha512
    })
    adap.expects(:get_raw_password_from_ad).with("foo", "virtualCryptSHA512").returns("secret_sha512\n")
    result = adap.get_password_hash("foo", nil)
    assert_equal(result, 'secret_sha512')
  end
end
