require "test_helper"

class ModAdapTest < Minitest::Test
  def test_adap_add_group_if_not_existed_test_should_return_success_if_the_group_has_already_existed
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    entry = {:cn => "Foo", :gidnumber => 1000, :operations => [[:add, :memberuid, "taro"]]}

    adap = get_general_adap_instance()
    mock[:ldap_client].expects(:search).with({:base => "cn=Foo,#{LDAP_BASE_OF_GROUP}"})
    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    ret = adap.add_group_if_not_existed("cn=Foo,#{LDAP_BASE_OF_GROUP}", entry)
    assert_equal({:code => 0, :operations => nil, :message => nil}, ret)
  end

  def test_adap_add_group_if_not_existed_test_should_return_error_if_ldapsearch_has_failed
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    entry = {:cn => "Foo", :gidnumber => 1000, :operations => [[:add, :memberuid, "taro"]]}

    adap = get_general_adap_instance()
    mock[:ldap_client].expects(:search).with({:base => "cn=Foo,#{LDAP_BASE_OF_GROUP}"})
    mock_ldap_get_operation_result.expects(:code).returns(1)    # Fail
    mock_ldap_get_operation_result.expects(:error_message).returns("Some error")
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(2)

    ret = adap.add_group_if_not_existed("cn=Foo,#{LDAP_BASE_OF_GROUP}", entry)
    assert_equal({:code => 1, :operations => nil, :message => "Failed to search LDAP in add_group_if_not_existed(). Some error"}, ret)
  end

  def test_adap_add_group_if_not_existed_test_should_return_error_if_ldapadd_operation_has_failed
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    entry = {:cn => "Foo", :gidnumber => 1000, :operations => [[:add, :memberuid, "taro"]]}

    adap = get_general_adap_instance()
    mock[:ldap_client].expects(:search).with({:base => "cn=Foo,#{LDAP_BASE_OF_GROUP}"})
    mock_ldap_get_operation_result.expects(:code).returns(32, 1).times(2)
    mock_ldap_get_operation_result.expects(:error_message).returns("Some error")
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(3)

    mock[:ldap_client].expects(:add)
      .with({:dn => "cn=Foo,#{LDAP_BASE_OF_GROUP}", :attributes => {:objectclass => ["top", "posixGroup"], :gidnumber => 1000, :cn => "Foo"}})

    ret = adap.add_group_if_not_existed("cn=Foo,#{LDAP_BASE_OF_GROUP}", entry)
    assert_equal({:code => 1, :operations => [:add_group], :message => "Failed to add a group in add_group_if_not_existed(). Some error"}, ret)
  end

  def test_adap_add_group_if_not_existed_test_should_return_success
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    entry = {:cn => "Foo", :gidnumber => 1000, :operations => [[:add, :memberuid, "taro"]]}

    adap = get_general_adap_instance()
    mock[:ldap_client].expects(:search).with({:base => "cn=Foo,#{LDAP_BASE_OF_GROUP}"})
    mock_ldap_get_operation_result.expects(:code).returns(32, 0).times(2)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(2)

    mock[:ldap_client].expects(:add)
      .with({:dn => "cn=Foo,#{LDAP_BASE_OF_GROUP}", :attributes => {:objectclass => ["top", "posixGroup"], :gidnumber => 1000, :cn => "Foo"}})

    ret = adap.add_group_if_not_existed("cn=Foo,#{LDAP_BASE_OF_GROUP}", entry)
    assert_equal({:code => 0, :operations => [:add_group], :message => nil}, ret)
  end

  def test_adap_add_group_if_not_existed_test_should_return_success_even_if_gidnumber_is_missing
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    entry = {:cn => "Foo", :operations => [[:add, :memberuid, "taro"]]}    # :gidnumber is missing

    adap = get_general_adap_instance()
    mock[:ldap_client].expects(:search).with({:base => "cn=Foo,#{LDAP_BASE_OF_GROUP}"})
    mock_ldap_get_operation_result.expects(:code).returns(32, 0).times(2)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(2)

    mock[:ldap_client].expects(:add)
      .with({:dn => "cn=Foo,#{LDAP_BASE_OF_GROUP}", :attributes => {:objectclass => ["top", "posixGroup"], :cn => "Foo"}})  # :gidnumber is missing

    ret = adap.add_group_if_not_existed("cn=Foo,#{LDAP_BASE_OF_GROUP}", entry)
    assert_equal({:code => 0, :operations => [:add_group], :message => nil}, ret)
  end

  def test_adap_add_group_if_not_existed_test_should_return_success_even_if_cn_is_missing
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    entry = {:gidnumber => 1000, :operations => [[:add, :memberuid, "taro"]]}

    adap = get_general_adap_instance()
    mock[:ldap_client].expects(:search).with({:base => "cn=Foo,#{LDAP_BASE_OF_GROUP}"})
    mock_ldap_get_operation_result.expects(:code).returns(32, 0).times(2)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(2)

    mock[:ldap_client].expects(:add)
      .with({:dn => "cn=Foo,#{LDAP_BASE_OF_GROUP}", :attributes => {:objectclass => ["top", "posixGroup"], :gidnumber => 1000}})

    ret = adap.add_group_if_not_existed("cn=Foo,#{LDAP_BASE_OF_GROUP}", entry)
    assert_equal({:code => 0, :operations => [:add_group], :message => nil}, ret)
  end
end
