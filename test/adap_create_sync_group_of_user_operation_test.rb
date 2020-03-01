require "test_helper"

class ModAdapTest < Minitest::Test
  def test_create_sync_group_of_user_operation_should_return_an_add_operation
    ret = get_general_adap_instance()
      .create_sync_group_of_user_operation({"Domain Admins" => {:gidnumber => 512}}, {}, "foo")

    assert_equal({
      "cn=Domain Admins,ou=Groups,dc=mysite,dc=example,dc=com" => {
        :cn => "Domain Admins",
        :gidnumber => 512,
        :operations => [[:add, :memberuid, "foo"]]
      }
    }, ret)
  end

  def test_create_sync_group_of_user_operation_should_return_some_add_operations
    ret = get_general_adap_instance
      .create_sync_group_of_user_operation({"Domain Admins" => {:gidnumber => 512}, "Domain Users" => {:gidnumber => 513}}, {}, "foo")

    assert_equal({
      "cn=Domain Admins,ou=Groups,dc=mysite,dc=example,dc=com" => {
        :cn => "Domain Admins",
        :gidnumber => 512,
        :operations => [[:add, :memberuid, "foo"]]
      },
      "cn=Domain Users,ou=Groups,dc=mysite,dc=example,dc=com" => {
        :cn => "Domain Users",
        :gidnumber => 513,
        :operations => [[:add, :memberuid, "foo"]]
      }
    }, ret)
  end

  def test_create_sync_group_of_user_operation_should_return_a_delete_operation
    ret = get_general_adap_instance
      .create_sync_group_of_user_operation({}, {"Domain Admins" => nil}, "foo")

    assert_equal({
      "cn=Domain Admins,ou=Groups,dc=mysite,dc=example,dc=com" => {
        :operations => [[:delete, :memberuid, "foo"]]
      }
    }, ret)
  end

  def test_create_sync_group_of_user_operation_should_return_some_delete_operations
    ret = get_general_adap_instance
      .create_sync_group_of_user_operation({}, {"Domain Admins" => nil, "Domain Users" => nil}, "foo")

    assert_equal({
      "cn=Domain Admins,ou=Groups,dc=mysite,dc=example,dc=com" => {
        :operations => [[:delete, :memberuid, "foo"]]
      },
      "cn=Domain Users,ou=Groups,dc=mysite,dc=example,dc=com" => {
        :operations => [[:delete, :memberuid, "foo"]]
      }
    }, ret)
  end

  def test_create_sync_group_of_user_operation_should_return_an_add_and_a_delete_operations
    ret = get_general_adap_instance
      .create_sync_group_of_user_operation({"Domain Users" => {:gidnumber => 513}}, {"Domain Admins" => nil}, "foo")

    assert_equal({
      "cn=Domain Admins,ou=Groups,dc=mysite,dc=example,dc=com" => {
        :operations => [[:delete, :memberuid, "foo"]]
      },
      "cn=Domain Users,ou=Groups,dc=mysite,dc=example,dc=com" => {
        :cn => "Domain Users",
        :gidnumber => 513,
        :operations => [[:add, :memberuid, "foo"]]
      }
    }, ret)
  end

  def test_create_sync_group_of_user_operation_should_return_some_add_and_some_delete_operations
    ret = get_general_adap_instance
      .create_sync_group_of_user_operation(
        {"Domain Users" => {:gidnumber => 513}, "Foo" => {:gidnumber => 1000}},
        {"Domain Admins" => nil, "Bar" => nil},
        "foo"
      )

    assert_equal({
      "cn=Domain Admins,ou=Groups,dc=mysite,dc=example,dc=com" => {
        :operations => [[:delete, :memberuid, "foo"]]
      },
      "cn=Bar,ou=Groups,dc=mysite,dc=example,dc=com" => {
        :operations => [[:delete, :memberuid, "foo"]]
      },
      "cn=Domain Users,ou=Groups,dc=mysite,dc=example,dc=com" => {
        :cn => "Domain Users",
        :gidnumber => 513,
        :operations => [[:add, :memberuid, "foo"]]
      },
      "cn=Foo,ou=Groups,dc=mysite,dc=example,dc=com" => {
        :cn => "Foo",
        :gidnumber => 1000,
        :operations => [[:add, :memberuid, "foo"]]
      }
    }, ret)
  end

  def test_create_sync_group_of_user_operation_should_return_no_operation
    ret = get_general_adap_instance
      .create_sync_group_of_user_operation(
        {"Domain Admins" => {:gidnumber => 512}, "Domain Users" => {:gidnumber => 513}},
        {"Domain Admins" => nil, "Domain Users" => nil},
        "foo"
      )

    assert_equal({}, ret)
  end
end
