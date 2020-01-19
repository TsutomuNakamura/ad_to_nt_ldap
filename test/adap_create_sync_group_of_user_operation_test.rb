require "test_helper"

class ModAdapTest < Minitest::Test
  def test_create_sync_group_of_user_operation_should_return_an_add_operation
    mock = mock_ad_and_ldap_connections()
    ret = get_general_adap_instance
      .create_sync_group_of_user_operation({"Domain Admins" => nil}, {}, "foo")

    assert_equal({
      "cn=Domain Admins,ou=Groups,dc=mysite,dc=example,dc=com" => [[:add, :memberuid, "foo"]]
    }, ret)
  end

  def test_create_sync_group_of_user_operation_should_return_some_add_operations
    mock = mock_ad_and_ldap_connections()
    ret = get_general_adap_instance
      .create_sync_group_of_user_operation({"Domain Admins" => nil, "Domain Users" => nil}, {}, "foo")

    assert_equal({
      "cn=Domain Admins,ou=Groups,dc=mysite,dc=example,dc=com" => [[:add, :memberuid, "foo"]],
      "cn=Domain Users,ou=Groups,dc=mysite,dc=example,dc=com" => [[:add, :memberuid, "foo"]]
    }, ret)
  end

  def test_create_sync_group_of_user_operation_should_return_a_delete_operation
    mock = mock_ad_and_ldap_connections()
    ret = get_general_adap_instance
      .create_sync_group_of_user_operation({}, {"Domain Admins" => nil}, "foo")

    assert_equal({
      "cn=Domain Admins,ou=Groups,dc=mysite,dc=example,dc=com" => [[:delete, :memberuid, "foo"]]
    }, ret)
  end

  def test_create_sync_group_of_user_operation_should_return_some_delete_operations
    mock = mock_ad_and_ldap_connections()
    ret = get_general_adap_instance
      .create_sync_group_of_user_operation({}, {"Domain Admins" => nil, "Domain Users" => nil}, "foo")

    assert_equal({
      "cn=Domain Admins,ou=Groups,dc=mysite,dc=example,dc=com" => [[:delete, :memberuid, "foo"]],
      "cn=Domain Users,ou=Groups,dc=mysite,dc=example,dc=com" => [[:delete, :memberuid, "foo"]]
    }, ret)
  end

  def test_create_sync_group_of_user_operation_should_return_an_add_and_a_delete_operations
    mock = mock_ad_and_ldap_connections()
    ret = get_general_adap_instance
      .create_sync_group_of_user_operation({"Domain Users" => nil}, {"Domain Admins" => nil}, "foo")

    assert_equal({
      "cn=Domain Admins,ou=Groups,dc=mysite,dc=example,dc=com" => [[:delete, :memberuid, "foo"]],
      "cn=Domain Users,ou=Groups,dc=mysite,dc=example,dc=com" => [[:add, :memberuid, "foo"]]
    }, ret)
  end

  def test_create_sync_group_of_user_operation_should_return_some_add_and_some_delete_operations
    mock = mock_ad_and_ldap_connections()
    ret = get_general_adap_instance
      .create_sync_group_of_user_operation({"Domain Users" => nil, "Foo" => nil}, {"Domain Admins" => nil, "Bar" => nil}, "foo")

    assert_equal({
      "cn=Domain Admins,ou=Groups,dc=mysite,dc=example,dc=com" => [[:delete, :memberuid, "foo"]],
      "cn=Bar,ou=Groups,dc=mysite,dc=example,dc=com" => [[:delete, :memberuid, "foo"]],
      "cn=Domain Users,ou=Groups,dc=mysite,dc=example,dc=com" => [[:add, :memberuid, "foo"]],
      "cn=Foo,ou=Groups,dc=mysite,dc=example,dc=com" => [[:add, :memberuid, "foo"]]
    }, ret)
  end

  def test_create_sync_group_of_user_operation_should_return_no_operation
    mock = mock_ad_and_ldap_connections()
    ret = get_general_adap_instance
      .create_sync_group_of_user_operation({"Domain Admins" => nil, "Domain Users" => nil}, {"Domain Admins" => nil, "Domain Users" => nil}, "foo")

    assert_equal({}, ret)
  end
end
