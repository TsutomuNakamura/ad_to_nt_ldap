
require "test_helper"

class ModAdapTest < Minitest::Test
  def test_create_modify_operations_should_create_operation_that_replace_password
    adap = get_general_adap_instance()

    operations = adap.create_modify_operations({}, {}, "ad_secret")
    assert_equal([
      [:replace, :userpassword, "ad_secret"]
    ], operations)
  end

  def test_create_modify_operations_should_create_operation_that_replace_password_except_others
    adap = get_general_adap_instance()

    operations = adap.create_modify_operations({:cn => "foo"}, {:cn => "foo"}, "ad_secret")
    assert_equal([
      [:replace, :userpassword, "ad_secret"]
    ], operations)
  end

  def test_create_modify_operations_should_create_operation_that_replace_cn
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

  def test_create_modify_operations_should_create_operation_that_has_add_a_msds_phonetic
    adap = get_general_adap_instance({
      :map_msds_phonetics => {
        :'msds-phoneticcompanyname' => :'companyname;lang-ja;phonetic'
      }
    })
    ret = adap.create_modify_operations(
      {:cn => "cn", :sn => "sn", :'msds-phoneticcompanyname' => "ほげかぶしきがいしゃ"},
      {:cn => "cn", :sn => "sn"},
      "ad_secret"
    )
    assert_equal([
      [:add, :'companyname;lang-ja;phonetic', "ほげかぶしきがいしゃ"],
      [:replace, :userpassword, "ad_secret"]
    ], ret)
  end

  def test_create_modify_operations_should_create_operation_that_has_add_msds_phonetics
    adap = get_general_adap_instance({
      :map_msds_phonetics => {
        :'msds-phoneticcompanyname' => :'companyname;lang-ja;phonetic',
        :'msds-phoneticdepartment' => :'department;lang-ja;phonetic'
      }
    })
    ret = adap.create_modify_operations(
      {:cn => "cn", :sn => "sn", :'msds-phoneticcompanyname' => "ほげかぶしきがいしゃ", :'msds-phoneticdepartment' => "かいはつぶ"},
      {:cn => "cn", :sn => "sn"},
      "ad_secret"
    )
    assert_equal([
      [:add, :'companyname;lang-ja;phonetic', "ほげかぶしきがいしゃ"],
      [:add, :'department;lang-ja;phonetic', "かいはつぶ"],
      [:replace, :userpassword, "ad_secret"]
    ], ret)
  end

  def test_create_modify_operations_should_create_operation_that_has_replace_a_msds_phonetic
    adap = get_general_adap_instance({
      :map_msds_phonetics => {
        :'msds-phoneticcompanyname' => :'companyname;lang-ja;phonetic'
      }
    })
    ret = adap.create_modify_operations(
      {:cn => "cn", :sn => "sn", :'msds-phoneticcompanyname' => "ほげかぶしきがいしゃ"},
      {:cn => "cn", :sn => "sn", :'companyname;lang-ja;phonetic' => "ふがかぶしきがいしゃ"},
      "ad_secret"
    )
    assert_equal([
      [:replace, :'companyname;lang-ja;phonetic', "ほげかぶしきがいしゃ"],
      [:replace, :userpassword, "ad_secret"]
    ], ret)
  end

  def test_create_modify_operations_should_create_operation_that_has_replace_msds_phonetics
    adap = get_general_adap_instance({
      :map_msds_phonetics => {
        :'msds-phoneticcompanyname' => :'companyname;lang-ja;phonetic',
        :'msds-phoneticdepartment' => :'department;lang-ja;phonetic'
      }
    })
    ret = adap.create_modify_operations(
      {:cn => "cn", :sn => "sn", :'msds-phoneticcompanyname' => "ほげかぶしきがいしゃ", :'msds-phoneticdepartment' => "かいはつぶ"},
      {:cn => "cn", :sn => "sn", :'companyname;lang-ja;phonetic' => "ふがかぶしきがいしゃ", :'department;lang-ja;phonetic' => "えいぎょうぶ"},
      "ad_secret"
    )
    assert_equal([
      [:replace, :'companyname;lang-ja;phonetic', "ほげかぶしきがいしゃ"],
      [:replace, :'department;lang-ja;phonetic', "かいはつぶ"],
      [:replace, :userpassword, "ad_secret"]
    ], ret)
  end

  def test_create_modify_operations_should_create_operation_that_has_delete_a_msds_phonetic
    adap = get_general_adap_instance({
      :map_msds_phonetics => {
        :'msds-phoneticcompanyname' => :'companyname;lang-ja;phonetic'
      }
    })
    ret = adap.create_modify_operations(
      {:cn => "cn", :sn => "sn"},
      {:cn => "cn", :sn => "sn", :'companyname;lang-ja;phonetic' => "ほげかぶしきがいしゃ"},
      "ad_secret"
    )
    assert_equal([
      [:delete, :'companyname;lang-ja;phonetic', nil],
      [:replace, :userpassword, "ad_secret"]
    ], ret)
  end

  def test_create_modify_operations_should_create_operation_that_has_delete_msds_phonetics
    adap = get_general_adap_instance({
      :map_msds_phonetics => {
        :'msds-phoneticcompanyname' => :'companyname;lang-ja;phonetic',
        :'msds-phoneticdepartment' => :'department;lang-ja;phonetic'
      }
    })
    ret = adap.create_modify_operations(
      {:cn => "cn", :sn => "sn"},
      {:cn => "cn", :sn => "sn", :'companyname;lang-ja;phonetic' => "ほげかぶしきがいしゃ", :'department;lang-ja;phonetic' => "かいはつぶ"},
      "ad_secret"
    )
    assert_equal([
      [:delete, :'companyname;lang-ja;phonetic', nil],
      [:delete, :'department;lang-ja;phonetic', nil],
      [:replace, :userpassword, "ad_secret"]
    ], ret)
  end

  def test_create_modify_operations_should_create_operation_that_has_multi_operations
    adap = get_general_adap_instance({
      :map_msds_phonetics => {
        :'msds-phoneticcompanyname' => :'companyname;lang-ja;phonetic',
        :'msds-phoneticdepartment' => :'department;lang-ja;phonetic',
        :'msds-phoneticfirstname' => :'firstname;lang-ja;phonetic',
        :'msds-phoneticlastname' => :'lastname;lang-ja;phonetic',
        :'msds-phoneticdisplayname' => :'displayname;lang-ja;phonetic'
      }
    })
    ret = adap.create_modify_operations(
      {
        :cn => "ad_cn",                                         # replace
        :sn => "ad_sn",                                         # replace
        :uid => "taro-suzuki",                                  # add
        :'msds-phoneticcompanyname' => "ほげかぶしきがいしゃ",  # add
        :'msds-phoneticdepartment' => "かいはつぶ",             # add
        :'msds-phoneticfirstname' => "たろう",                  # replace
        :'msds-phoneticlastname' => "すずき"                   # replace
      },
      {
        :cn => "ldap_cn",
        :sn => "ldap_sn",
        :uidnumber => 1000,                                     # delete
        :gidnumber => 1000,                                     # delete
        :'firstname;lang-ja;phonetic' => "じろう",
        :'lastname;lang-ja;phonetic' => "たなか",
        :'displayname;lang-ja;phonetic' => "たなか　じろう"    # delete
      },
      "ad_secret"
    )
    assert_equal([
      [:replace, :cn, "ad_cn"],
      [:replace, :sn, "ad_sn"],
      [:add, :uid, "taro-suzuki"],
      [:add, :'companyname;lang-ja;phonetic', "ほげかぶしきがいしゃ"],
      [:add, :'department;lang-ja;phonetic', "かいはつぶ"],
      [:replace, :'firstname;lang-ja;phonetic', "たろう"],
      [:replace, :'lastname;lang-ja;phonetic', "すずき"],
      [:delete, :uidnumber, nil],
      [:delete, :gidnumber, nil],
      [:delete, :'displayname;lang-ja;phonetic', nil],
      [:replace, :userpassword, "ad_secret"]
    ], ret)
  end
end
