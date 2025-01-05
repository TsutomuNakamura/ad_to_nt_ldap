require "test_helper"

class ModAdapTest < Minitest::Test
  def test_delete_group_if_existed_as_empty_return_success_if_the_group_has_some_memberuid
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    mock[:ldap_client].expects(:search)
      .with(:base => "cn=Foo,#{LDAP_GROUP_BASE}", :filter => "(!(memberUid=*))")  # Yields nothing if the group has memberuids
    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    adap = get_general_adap_instance()
    ret = adap.delete_group_if_existed_as_empty("cn=Foo,#{LDAP_GROUP_BASE}")
    assert_equal({:code => 0, :operations => nil, :message => nil}, ret)
  end

  def test_delete_group_if_existed_as_empty_return_success_if_the_group_has_already_deleted
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    mock[:ldap_client].expects(:search)
      .with(:base => "cn=Foo,#{LDAP_GROUP_BASE}", :filter => "(!(memberUid=*))")
    mock_ldap_get_operation_result.expects(:code).returns(32)  # Return 32 if the group has already deleted
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    adap = get_general_adap_instance()
    ret = adap.delete_group_if_existed_as_empty("cn=Foo,#{LDAP_GROUP_BASE}")
    assert_equal({:code => 0, :operations => nil, :message => nil}, ret)
  end

  def test_delete_group_if_existed_as_empty_return_failed_if_ldapsearch_returns_error
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    mock[:ldap_client].expects(:search)
      .with(:base => "cn=Foo,#{LDAP_GROUP_BASE}", :filter => "(!(memberUid=*))")
    mock_ldap_get_operation_result.expects(:code).returns(1)  # Some error
    mock_ldap_get_operation_result.expects(:error_message).returns("Some error")
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(2)

    adap = get_general_adap_instance()
    ret = adap.delete_group_if_existed_as_empty("cn=Foo,#{LDAP_GROUP_BASE}")
    assert_equal({:code => 1, :operations => nil, :message => "Failed to search group in delete_group_if_existed_as_empty(). Some error"}, ret)
  end

  def test_delete_group_if_existed_as_empty_return_failed_if_ldapdelete_returns_error
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    mock[:ldap_client].expects(:search)
      .with(:base => "cn=Foo,#{LDAP_GROUP_BASE}", :filter => "(!(memberUid=*))")
      .yields("Some entry")
    mock_ldap_get_operation_result.expects(:code).returns(0, 1).times(2)  # Failed
    mock_ldap_get_operation_result.expects(:error_message).returns("Some error")
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(3)
    mock[:ldap_client].expects(:delete).with(:dn => "cn=Foo,#{LDAP_GROUP_BASE}")

    adap = get_general_adap_instance()
    ret = adap.delete_group_if_existed_as_empty("cn=Foo,#{LDAP_GROUP_BASE}")
    assert_equal({:code => 1, :operations => [:delete_group], :message => "Failed to delete a group in delete_group_if_existed_as_empty(). Some error"}, ret)
  end

  def test_delete_group_if_existed_as_empty_return_success_if_ldapdelete_returns_success
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    mock[:ldap_client].expects(:search)
      .with(:base => "cn=Foo,#{LDAP_GROUP_BASE}", :filter => "(!(memberUid=*))")
      .yields("Some entry")
    mock_ldap_get_operation_result.expects(:code).returns(0, 0).times(2)  # Failed
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(2)
    mock[:ldap_client].expects(:delete).with(:dn => "cn=Foo,#{LDAP_GROUP_BASE}")

    adap = get_general_adap_instance()
    ret = adap.delete_group_if_existed_as_empty("cn=Foo,#{LDAP_GROUP_BASE}")
    assert_equal({:code => 0, :operations => [:delete_group], :message => nil}, ret)
  end
end
