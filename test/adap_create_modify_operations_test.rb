
require "test_helper"

class ModAdapTest < Minitest::Test

  def test_create_modify_operations_should_create_operation_that_replace_password
    mock_ldap = MiniTest::Mock.new

    Net::LDAP.stub :new, mock_ldap do
      adap = Adap.new({
        :ad_host => "localhost",
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_basedn => "dc=mysite,dc=example,dc=com"
      })

      operations = adap.create_modify_operations({}, {}, "secret")
      assert_equal([
        [:replace, :userpassword, "secret"]
      ], operations)
    end
  end

  def test_create_modify_operations_should_create_operation_that_replace_cn
    mock_ldap = MiniTest::Mock.new

    Net::LDAP.stub :new, mock_ldap do
      adap = Adap.new({
        :ad_host => "localhost",
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_basedn => "dc=mysite,dc=example,dc=com"
      })

      operations = adap.create_modify_operations(
        {:cn => "cn_ad"},
        {:cn => "cn_ldap"},
        "secret"
      )
      assert_equal([
        [:replace, :cn, "cn_ad"],
        [:replace, :userpassword, "secret"]
      ], operations)
    end
  end

  def test_create_modify_operations_should_create_operation_that_add_cn
    mock_ldap = MiniTest::Mock.new

    Net::LDAP.stub :new, mock_ldap do
      adap = Adap.new({
        :ad_host => "localhost",
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_basedn => "dc=mysite,dc=example,dc=com"
      })

      operations = adap.create_modify_operations(
        {:cn => "cn_ad"},
        {},
        "secret"
      )
      assert_equal([
        [:add, :cn, "cn_ad"],
        [:replace, :userpassword, "secret"]
      ], operations)
    end
  end

  def test_create_modify_operations_should_create_operation_that_delete_cn
    mock_ldap = MiniTest::Mock.new

    Net::LDAP.stub :new, mock_ldap do
      adap = Adap.new({
        :ad_host => "localhost",
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_basedn => "dc=mysite,dc=example,dc=com"
      })

      operations = adap.create_modify_operations(
        {},
        {:cn => "cn_ldap"},
        "secret"
      )
      assert_equal([
        [:delete, :cn, nil],
        [:replace, :userpassword, "secret"]
      ], operations)
    end
  end

  def test_create_modify_operations_should_create_operation_that_has_add_and_replace_and_delete
    mock_ldap = MiniTest::Mock.new

    Net::LDAP.stub :new, mock_ldap do
      adap = Adap.new({
        :ad_host => "localhost",
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :ldap_host   => "ldap_server",
        :ldap_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :ldap_basedn => "dc=mysite,dc=example,dc=com"
      })

      operations = adap.create_modify_operations(
        {:cn => "cn_ad",  :sn => "sn_ad"},
        {:cn => "cn_ldap", :displayname => "displayname_ldap"},
        "secret"
      )

      assert_equal(4, operations.length, msg=operations)
      assert_equal(1, operations.select{|x, _| x == :add}.length)
      assert_equal(1, operations.select{|x, y| x == :replace && y == :cn}.length)
      assert_equal(1, operations.select{|x, y| x == :replace && y == :userpassword}.length)
      assert_equal(1, operations.select{|x, _| x == :delete}.length)
      assert_equal([:add, :sn, "sn_ad"], operations.select{|x, _| x == :add}[0])
      assert_equal([:replace, :cn, "cn_ad"], operations.select{|x, y| x == :replace && y == :cn}[0])
      assert_equal([:replace, :userpassword, "secret"], operations.select{|x, y| x == :replace && y == :userpassword}[0])
      assert_equal([:delete, :displayname, nil], operations.select{|x, _| x == :delete}[0])
    end
  end

end
