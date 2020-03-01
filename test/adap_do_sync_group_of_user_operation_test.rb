require "test_helper"

class ModAdapTest < Minitest::Test
  def test_do_sync_group_of_user_operation_should_return_0

    adap = get_general_adap_instance()
    ret = adap.do_sync_group_of_user_operation({})
    assert_equal({:code => 0, :operations => nil, :message => "There are not any groups of user to sync"}, ret)
  end

  def test_do_sync_group_of_user_operation_should_return_error_if_add_group_if_not_existed_returns_not_0

    operation_pool = {
      "cn=Foo,#{LDAP_BASE_OF_GROUP}" => {
        :cn => "Foo",
        :gidnumber => 1000,
        :operations => [[:add, :memberuid, "taro"]]    # Add operation
      }
    }

    adap = get_general_adap_instance()
    adap.expects(:add_group_if_not_existed)
      .with("cn=Foo,#{LDAP_BASE_OF_GROUP}", operation_pool["cn=Foo,#{LDAP_BASE_OF_GROUP}"])
      .returns({:code => 1, :operations => [:some_operation], :message => "Some error"})    # Returns fail

    ret = adap.do_sync_group_of_user_operation(operation_pool)
    assert_equal({:code => 1, :operations => [:some_operation], :message => "Some error"}, ret)
  end

  def test_do_sync_group_of_user_operation_should_return_error_if_ldapmodify_returns_error
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    operation_pool = {
      "cn=Foo,#{LDAP_BASE_OF_GROUP}" => {
        :cn => "Foo",
        :gidnumber => 1000,
        :operations => [[:add, :memberuid, "taro"]]
      }
    }

    adap = get_general_adap_instance()
    adap.expects(:add_group_if_not_existed)
      .with("cn=Foo,#{LDAP_BASE_OF_GROUP}", operation_pool["cn=Foo,#{LDAP_BASE_OF_GROUP}"])
      .returns({:code => 0, :operations => nil, :message => nil})
    mock[:ldap_client].expects(:modify)
      .with({:dn => "cn=Foo,#{LDAP_BASE_OF_GROUP}", :operations => operation_pool["cn=Foo,#{LDAP_BASE_OF_GROUP}"][:operations]})
    mock_ldap_get_operation_result.expects(:code).returns(1)    # Retrun fail
    mock_ldap_get_operation_result.expects(:error_message).returns("Some error")
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(2)

    ret = adap.do_sync_group_of_user_operation(operation_pool)
    assert_equal({
      :code => 1,
      :operations => [:modify_group_of_user],
      :message => "Failed to modify group \"cn=Foo,#{LDAP_BASE_OF_GROUP}\" of user Foo. Some error"}, ret)
  end

  def test_do_sync_group_of_user_operation_should_return_error_if_delete_group_if_existed_as_empty_returns_error
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    operation_pool = {
      "cn=Foo,#{LDAP_BASE_OF_GROUP}" => {
        :cn => "Foo",
        :gidnumber => 1000,
        :operations => [[:delete, :memberuid, "taro"]]    # Delete operation
      }
    }

    adap = get_general_adap_instance()
    #adap.expects(:add_group_if_not_existed)
    #  .with("cn=Foo,#{LDAP_BASE_OF_GROUP}", operation_pool["cn=Foo,#{LDAP_BASE_OF_GROUP}"])
    #  .returns({:code => 0, :operations => nil, :message => nil})
    mock[:ldap_client].expects(:modify)
      .with({:dn => "cn=Foo,#{LDAP_BASE_OF_GROUP}", :operations => operation_pool["cn=Foo,#{LDAP_BASE_OF_GROUP}"][:operations]})
    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)
    adap.expects(:delete_group_if_existed_as_empty)
      .with("cn=Foo,#{LDAP_BASE_OF_GROUP}")
      .returns({:code => 1, :operations => [:delete_group_of_user], :message => "Some error"})    # Return fail

    ret = adap.do_sync_group_of_user_operation(operation_pool)
    assert_equal({:code => 1, :operations => [:delete_group_of_user], :message => "Some error"}, ret)
  end

  def test_do_sync_group_of_user_operation_should_return_success_if_there_is_a_single_add_operation
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    operation_pool = {
      "cn=Foo,#{LDAP_BASE_OF_GROUP}" => {
        :cn => "Foo", :gidnumber => 1000, :operations => [[:add, :memberuid, "taro"]]
      }
    }

    adap = get_general_adap_instance()
    adap.expects(:add_group_if_not_existed)
      .with("cn=Foo,#{LDAP_BASE_OF_GROUP}", operation_pool["cn=Foo,#{LDAP_BASE_OF_GROUP}"])
      .returns({:code => 0, :operations => nil, :message => nil})
    mock[:ldap_client].expects(:modify)
      .with({:dn => "cn=Foo,#{LDAP_BASE_OF_GROUP}", :operations => operation_pool["cn=Foo,#{LDAP_BASE_OF_GROUP}"][:operations]})
    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    ret = adap.do_sync_group_of_user_operation(operation_pool)
    assert_equal({:code => 0, :operations => [:modify_group_of_user], :message => nil}, ret)
  end

  def test_do_sync_group_of_user_operation_should_return_success_if_there_are_add_and_delete_operations
    mock                            = mock_ad_and_ldap_connections()
    mock_ldap_get_operation_result  = mock()

    operation_pool = {
      "cn=Foo,#{LDAP_BASE_OF_GROUP}" => {
        :cn => "Foo", :gidnumber => 1000, :operations => [[:add, :memberuid, "taro"]],
      },
      "cn=Bar,#{LDAP_BASE_OF_GROUP}" => {
        :cn => "Bar", :gidnumber => 1001, :operations => [[:delete, :memberuid, "taro"]]
      }
    }

    adap = get_general_adap_instance()
    adap.expects(:add_group_if_not_existed)
      .with("cn=Foo,#{LDAP_BASE_OF_GROUP}", operation_pool["cn=Foo,#{LDAP_BASE_OF_GROUP}"])
      .returns({:code => 0, :operations => nil, :message => nil})
    mock[:ldap_client].expects(:modify)
      .with({:dn => "cn=Foo,#{LDAP_BASE_OF_GROUP}", :operations => operation_pool["cn=Foo,#{LDAP_BASE_OF_GROUP}"][:operations]})
    mock[:ldap_client].expects(:modify)
      .with({:dn => "cn=Bar,#{LDAP_BASE_OF_GROUP}", :operations => operation_pool["cn=Bar,#{LDAP_BASE_OF_GROUP}"][:operations]})
    mock_ldap_get_operation_result.expects(:code).returns(0, 0).times(2)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(2)
    adap.expects(:delete_group_if_existed_as_empty)
      .with("cn=Bar,#{LDAP_BASE_OF_GROUP}")
      .returns({:code => 0, :operations => nil, :message => nil})

    ret = adap.do_sync_group_of_user_operation(operation_pool)
    assert_equal({:code => 0, :operations => [:modify_group_of_user], :message => nil}, ret)
  end
end
