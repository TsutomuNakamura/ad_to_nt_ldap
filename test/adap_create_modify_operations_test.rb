
require "test_helper"

class ModAdapTest < Minitest::Test
  def test_create_modify_operations_should_create_operation_that_replace_password
    mock = mock_ad_and_ldap_connections()
    adap = get_general_adap_instance()

    operations = adap.create_modify_operations({}, {}, "ad_secret")
    assert_equal([
      [:replace, :userpassword, "ad_secret"]
    ], operations)
  end

  def test_create_modify_operations_should_create_operation_that_replace_cn
    mock = mock_ad_and_ldap_connections()
    adap = get_general_adap_instance()

    operations = adap.create_modify_operations(
      {:cn => "cn_ad"},
      {:cn => "cn_ldap"},
      "ad_secret"
    )
    assert_equal([
      [:replace, :cn, "cn_ad"],
      [:replace, :userpassword, "ad_secret"]
    ], operations)
  end

  def test_create_modify_operations_should_create_operation_that_add_cn
    adap = get_general_adap_instance()

    operations = adap.create_modify_operations(
      {:cn => "cn_ad"},
      {},
      "ad_secret"
    )
    assert_equal([
      [:add, :cn, "cn_ad"],
      [:replace, :userpassword, "ad_secret"]
    ], operations)
  end

  def test_create_modify_operations_should_create_operation_that_has_duplicated_attributes
    adap = get_general_adap_instance()

    operations = adap.create_modify_operations(
      {:cn => "cn_ad",  :sn => "foo"},
      {:cn => "cn_ldap", :sn => "foo"},
      "ad_secret"
    )

    assert_equal([
      [:replace, :cn, "cn_ad"],
      [:replace, :userpassword, "ad_secret"]
    ], operations)
  end

  def test_create_modify_operations_should_create_operation_that_delete_cn
    adap = get_general_adap_instance()

    operations = adap.create_modify_operations(
      {},
      {:cn => "cn_ldap"},
      "ad_secret"
    )
    assert_equal([
      [:delete, :cn, nil],
      [:replace, :userpassword, "ad_secret"]
    ], operations)
  end

  def test_create_modify_operations_should_replace_unixhomedirectory_to_homedirectory
    adap = get_general_adap_instance()
    ret = adap.create_modify_operations(
      {:unixhomedirectory => "/home/foo"},
      {},
      "ad_secret"
    )
    assert_equal([
      [:add, :homedirectory, "/home/foo"],
      [:replace, :userpassword, "ad_secret"]
    ], ret)
  end

  def test_create_modify_operations_should_NOT_replace_homedirectory_to_unixhomedirectory
    adap = get_general_adap_instance()
    ret = adap.create_modify_operations(
      {},
      {:homedirectory => "/home/foo"},
      "ad_secret"
    )
    assert_equal([
      [:delete, :homedirectory, nil],
      [:replace, :userpassword, "ad_secret"]
    ], ret)
  end

  def test_create_modify_operations_should_create_operation_that_has_add_and_replace_and_delete
    adap = get_general_adap_instance()

    operations = adap.create_modify_operations(
      {:cn => "cn_ad",  :sn => "sn_ad"},
      {:cn => "cn_ldap", :displayname => "displayname_ldap"},
      "ad_secret"
    )

    assert_equal(4, operations.length, msg=operations)
    assert_equal(1, operations.select{|x, _| x == :add}.length)
    assert_equal(1, operations.select{|x, y| x == :replace && y == :cn}.length)
    assert_equal(1, operations.select{|x, y| x == :replace && y == :userpassword}.length)
    assert_equal(1, operations.select{|x, _| x == :delete}.length)
    assert_equal([:add, :sn, "sn_ad"], operations.select{|x, _| x == :add}[0])
    assert_equal([:replace, :cn, "cn_ad"], operations.select{|x, y| x == :replace && y == :cn}[0])
    assert_equal([:replace, :userpassword, "ad_secret"], operations.select{|x, y| x == :replace && y == :userpassword}[0])
    assert_equal([:delete, :displayname, nil], operations.select{|x, _| x == :delete}[0])
  end
end
