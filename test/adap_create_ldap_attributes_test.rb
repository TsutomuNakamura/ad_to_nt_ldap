require "test_helper"

class ModAdapTest < Minitest::Test
  def test_create_ldap_attribute_should_only_return_attributes_that_should_be_synced
    mock = mock_ad_and_ldap_connections()
    adap = get_general_adap_instance()

    result = adap.create_ldap_attributes({
      "uid"               => ["taro-suzuki"],
      "sn"                => ["鈴木太郎"],
      "objectCategory"    => ["CN=Person,CN=Schema,CN=Configuration,DC=example,DC=com"]
    })

    assert_equal(
      {
        :objectclass => ["top", "person", "organizationalPerson", "inetOrgPerson", "posixAccount", "shadowAccount"],
        :uid => ["taro-suzuki"],
        :sn => ["鈴木太郎"]
      },
      result
    )
  end

  def test_create_ldap_attribute_should_convert_some_attribute_names
    mock = mock_ad_and_ldap_connections()
    adap = get_general_adap_instance()

    result = adap.create_ldap_attributes({
      "uid"               => ["taro-suzuki"],
      "sn"                => ["鈴木太郎"],
      "unixHomeDirectory" => ["/home/taro-suzuki"]
    })

    assert_equal(
      {
        :objectclass => ["top", "person", "organizationalPerson", "inetOrgPerson", "posixAccount", "shadowAccount"],
        :uid => ["taro-suzuki"],
        :sn => ["鈴木太郎"],
        :homedirectory => ["/home/taro-suzuki"]
      },
      result
    )
  end

  def test_create_ldap_attribute_should_sync_one_phonetic
    mock = mock_ad_and_ldap_connections()
    adap = Adap.new({
      :ad_host        => "localhost",
      :ad_binddn      => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_basedn      => "DC=mysite,DC=example,DC=com",
      :ad_password    => "ad_secret",
      :ldap_host      => "ldap_server",
      :ldap_binddn    => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_basedn    => "dc=mysite,dc=example,dc=com",
      :ldap_password  => "ldap_secret",
      :map_msds_phonetics => {
        :'msds-phoneticcompanyname' => :'companyName;lang-ja;phonetic'
      }
    })

    result = adap.create_ldap_attributes({
      "uid"               => ["taro-suzuki"],
      "sn"                => ["鈴木太郎"],
      "msDS-PhoneticCompanyName" => ["ほげ株式会社"]
    })

    assert_equal(
      {
        :objectclass => ["top", "person", "organizationalPerson", "inetOrgPerson", "posixAccount", "shadowAccount"],
        :uid => ["taro-suzuki"],
        :sn => ["鈴木太郎"],
        :'companyName;lang-ja;phonetic' => ["ほげ株式会社"]
      },
      result
    )
  end

  def test_create_ldap_attribute_should_not_sync_one_phonetic
    # TODO
  end

  def test_create_ldap_attribute_should_sync_phonetics
    # TODO
  end

  def test_create_ldap_attribute_should_not_sync_phonetics
    # TODO
  end

  def test_create_ldap_attribute_should_sync_one_phonetic_and_not_sync_another_phonetic
    # TODO
  end

  def test_create_ldap_attribute_should_sync_phonetics_and_not_sync_others
    # TODO
  end
end

