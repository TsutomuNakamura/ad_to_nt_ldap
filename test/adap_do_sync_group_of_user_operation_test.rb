require "test_helper"

class ModAdapTest < Minitest::Test
  def test_do_sync_group_of_user_operation_should_return_0_if_the_length_of_operation_was_0
    mock = mock_ad_and_ldap_connections()

    adap = get_general_adap_instance()
    ret = adap.do_sync_group_of_user_operation({})
    assert_equal({:code => 0, :operations => nil, :message => "There are not any groups of user to sync"}, ret)
  end

  def test_do_sync_group_of_user_operation_should_
    mock = mock_ad_and_ldap_connections()

    adap = get_general_adap_instance()
    ret = adap.do_sync_group_of_user_operation({})
    assert_equal({:code => 0, :operations => nil, :message => "There are not any groups of user to sync"}, ret)
  end
end
