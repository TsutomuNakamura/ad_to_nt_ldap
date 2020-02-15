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
    adap = get_general_adap_instance({
      :map_msds_phonetics => {
        :'msds-phoneticcompanyname' => :'companyname;lang-ja;phonetic'
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
        :'companyname;lang-ja;phonetic' => ["ほげ株式会社"]
      },
      result
    )
  end

  def test_create_ldap_attribute_should_not_sync_one_phonetic
    mock = mock_ad_and_ldap_connections()
    adap = get_general_adap_instance()

    result = adap.create_ldap_attributes({
      "uid"               => ["taro-suzuki"],
      "sn"                => ["鈴木太郎"],
      "msDS-PhoneticCompanyName" => ["ほげ株式会社"]    # <- Expect not be synched
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

  def test_create_ldap_attribute_should_sync_phonetics
    mock = mock_ad_and_ldap_connections()
    adap = get_general_adap_instance({
      :map_msds_phonetics => {
        :'msds-phoneticcompanyname' => :'companyname;lang-ja;phonetic',
        :'msds-phoneticdisplayname' => :'displayname;lang-ja;phonetic'
      }
    })

    result = adap.create_ldap_attributes({
      "uid"               => ["taro-suzuki"],
      "sn"                => ["鈴木太郎"],
      "msDS-PhoneticCompanyName" => ["ほげ株式会社"],
      "msDS-PhoneticDisplayName" => ["てすと"]
    })

    assert_equal(
      {
        :objectclass => ["top", "person", "organizationalPerson", "inetOrgPerson", "posixAccount", "shadowAccount"],
        :uid => ["taro-suzuki"],
        :sn => ["鈴木太郎"],
        :'companyname;lang-ja;phonetic' => ["ほげ株式会社"],
        :'displayname;lang-ja;phonetic' => ["てすと"],
      },
      result
    )
  end

#  def test_create_ldap_attribute_should_not_sync_phonetics
#    # TODO
#  end
#
#  def test_create_ldap_attribute_should_sync_one_phonetic_and_not_sync_another_phonetic
#    # TODO
#  end
#
#  def test_create_ldap_attribute_should_sync_phonetics_and_not_sync_others
#    # TODO
#  end
end

