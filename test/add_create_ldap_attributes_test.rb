require "test_helper"

class ModAdapTest < Minitest::Test
  def test_create_ldap_attribute_should_only_return_attributes_that_should_be_synced
    mock = mock_ad_and_ldap_connections()

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
end

