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

    ret = add_group_if_not_existed("cn=Foo,#{LDAP_BASE_OF_GROUP}", entry)
    assert_equal({:code => 0, :operations => nil, :message => nil}, ret)
  end

  # TODO:
end
