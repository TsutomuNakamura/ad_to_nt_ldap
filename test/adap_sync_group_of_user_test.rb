require "test_helper"

class ModAdapTest < Minitest::Test
  def test_sync_group_of_user_should_call_ldap_client_search_without_gidfilter_if_parameter_of_gid_is_nil
    mock                            = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result    = mock()
    mock_ldap_get_operation_result  = mock()

    Net::LDAP::Filter.expects(:construct).with(DUMMY_LDAP_FILTER_OF_FOO_WITHOUT_GIDNUMBER).returns(DUMMY_LDAP_FILTER_OF_FOO_WITHOUT_GIDNUMBER)

    # Search ad group entry that belonging the user from AD
    mock[:ad_client].expects(:search)
      .with(:base => AD_GROUP_BASE, :filter => DUMMY_LDAP_FILTER_OF_FOO_WITHOUT_GIDNUMBER, :attributes => [:cn, :gidnumber])
      .yields({:cn => ["Domain Users"], :gidnumber => 513})

    mock_ad_get_operation_result.expects(:code).returns(0)
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    Net::LDAP::Filter.expects(:construct)
      .with("(memberUid=foo)")
      .returns("(memberUid=foo)")
    mock[:ldap_client].expects(:search)
      .with(:base => LDAP_GROUP_BASE, :filter => "(memberUid=foo)", :attributes => [:cn])
      .yields({:cn => ["Domain Users"]})

    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = get_general_adap_instance()
    adap.expects(:create_sync_group_of_user_operation)
      .with({"Domain Users" => {:gidnumber => 513}}, {"Domain Users" => nil}, "foo")
      .returns({})
    adap.expects(:do_sync_group_of_user_operation)
      .with({})
      .returns({:code => 0, :operations => nil, :message => "There are not any groups of user to sync"})

    ret = adap.sync_group_of_user("foo", nil)
    assert_equal({:code => 0, :operations => [:modify_group_of_user], :message => nil}, ret)
  end

  def test_sync_group_of_user_should_call_ldap_client_search_with_gidfilter_if_parameter_of_gid_is_not_nil
    mock                            = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result    = mock()
    mock_ldap_get_operation_result  = mock()

    Net::LDAP::Filter.expects(:construct)
      .with(DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513)
      .returns(DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513)

    # @ldap_client.modify
    mock[:ad_client].expects(:search)
      .with(:base => AD_GROUP_BASE, :filter => DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513, :attributes => [:cn, :gidnumber])
      .yields({:cn => ["Domain Users"], :gidnumber => 513})

    mock_ad_get_operation_result.expects(:code).returns(0)
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    Net::LDAP::Filter.expects(:construct)
      .with("(memberUid=foo)")
      .returns("(memberUid=foo)")
    mock[:ldap_client].expects(:search).with(:base => LDAP_GROUP_BASE, :filter => "(memberUid=foo)", :attributes => [:cn]).yields({:cn => ["Domain Users"]})

    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = get_general_adap_instance()
    adap.expects(:create_sync_group_of_user_operation)
      .with({"Domain Users" => {:gidnumber => 513}}, {"Domain Users" => nil}, "foo")
      .returns({})
    adap.expects(:do_sync_group_of_user_operation)
      .with({})
      .returns({:code => 0, :operations => nil, :message => "There are not any groups of user to sync"})

    ret = adap.sync_group_of_user("foo", 513)
    assert_equal({:code => 0, :operations => [:modify_group_of_user], :message => nil}, ret)
  end

  def test_sync_group_of_user_should_return_error_if_ad_search_has_failed
    mock                            = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result    = mock()
    #mock_ldap_get_operation_result  = mock()

    Net::LDAP::Filter.expects(:construct)
      .with(DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513)
      .returns(DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513)

    # @ldap_client.modify
    mock[:ad_client].expects(:search).with(
      :base => AD_GROUP_BASE,
      :filter => DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513,
      :attributes => [:cn, :gidnumber]
    ).yields({:cn => ["Domain Users"], :gidnumber => 513})

    mock_ad_get_operation_result.expects(:code).returns(1)    # ldapsearch to AD will fail
    mock_ad_get_operation_result.expects(:error_message).returns("Some error")
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result).times(2)

    # Testing from here
    adap = get_general_adap_instance()

    ret = adap.sync_group_of_user("foo", 513)
    assert_equal({:code => 1, :operations => [:search_groups_from_ad], :message => "Failed to get groups of a user foo from AD to sync them. Some error"}, ret)
  end

  def test_sync_group_of_user_should_return_error_if_ldap_search_has_failed
    mock                            = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result    = mock()
    mock_ldap_get_operation_result  = mock()

    Net::LDAP::Filter.expects(:construct)
      .with(DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513)
      .returns(DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513)

    # @ldap_client.modify
    mock[:ad_client].expects(:search)
      .with(
        :base => AD_GROUP_BASE,
        :filter => DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513,
        :attributes => [:cn, :gidnumber]
      ).yields({:cn => ["Domain Users"], :gidnumber => 513})

    mock_ad_get_operation_result.expects(:code).returns(0)
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    Net::LDAP::Filter.expects(:construct)
      .with("(memberUid=foo)")
      .returns("(memberUid=foo)")
    mock[:ldap_client].expects(:search)
      .with(
        :base => LDAP_GROUP_BASE,
        :filter => "(memberUid=foo)",
        :attributes => [:cn]
      ).yields({:cn => ["Domain Users"]})
    mock_ldap_get_operation_result.expects(:code).returns(1)
    mock_ldap_get_operation_result.expects(:error_message).returns("Some error")
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(2)

    # Testing from here
    adap = get_general_adap_instance()
    ret = adap.sync_group_of_user("foo", 513)
    assert_equal({:code => 1, :operations => [:search_groups_from_ldap], :message => "Failed to get groups of a user foo from LDAP to sync them. Some error"}, ret)
  end

  def test_sync_group_of_user_should_return_error_if_first_ldap_modify_has_failed
    mock                            = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result    = mock()
    mock_ldap_get_operation_result  = mock()

    Net::LDAP::Filter.expects(:construct)
      .with(DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513)
      .returns(DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513)

    # @ldap_client.modify
    mock[:ad_client].expects(:search)
      .with(
        :base => AD_GROUP_BASE, :filter => DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513, :attributes => [:cn, :gidnumber]
      ).multiple_yields({:cn => ["Domain Users"], :gidnumber => 513}, {:cn => ["Domain Admins"], :gidnumber => 512})

    mock_ad_get_operation_result.expects(:code).returns(0)
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    Net::LDAP::Filter.expects(:construct)
      .with("(memberUid=foo)")
      .returns("(memberUid=foo)")
    mock[:ldap_client].expects(:search).with(
      :base => LDAP_GROUP_BASE,
      :filter => "(memberUid=foo)",
      :attributes => [:cn]
    ).yields({:cn => ["Domain Users"]})
    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = get_general_adap_instance()
    adap.expects(:create_sync_group_of_user_operation)
      .with({"Domain Users" => {:gidnumber => 513}, "Domain Admins" => {:gidnumber => 512}}, {"Domain Users" => nil}, "foo")
      .returns({"cn=Domain Admins,#{LDAP_GROUP_BASE}" => [[:add, :memberuid, "foo"]]})
    adap.expects(:do_sync_group_of_user_operation)
      .with({"cn=Domain Admins,#{LDAP_GROUP_BASE}" => [[:add, :memberuid, "foo"]]})
      .returns({:code => 1, :operations => nil, :message => "Some error from do_sync_group_of_user_operation()"})  # will fail

    ret = adap.sync_group_of_user("foo", 513)
    assert_equal({
      :code => 1,
      :operations => [:modify_group_of_user],
      :message => "Some error from do_sync_group_of_user_operation()"}, ret)
  end

  def test_sync_group_of_user_should_return_success
    mock                            = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result    = mock()
    mock_ldap_get_operation_result  = mock()

    Net::LDAP::Filter.expects(:construct)
      .with(DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513)
      .returns(DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513)

    # @ldap_client.modify
    mock[:ad_client].expects(:search)
      .with(
        :base => AD_GROUP_BASE,
        :filter => DUMMY_LDAP_FILTER_OF_FOO_WITH_GIDNUMBER_513,
        :attributes => [:cn, :gidnumber]
      ).multiple_yields({:cn => ["Domain Users"], :gidnumber => 513}, {:cn => ["Domain Admins"], :gidnumber => 512})

    mock_ad_get_operation_result.expects(:code).returns(0)
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    Net::LDAP::Filter.expects(:construct)
      .with("(memberUid=foo)")
      .returns("(memberUid=foo)")
    mock[:ldap_client].expects(:search).with(
      :base => LDAP_GROUP_BASE,
      :filter => "(memberUid=foo)",
      :attributes => [:cn]
    ).yields({:cn => ["Domain Users"]})
    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = get_general_adap_instance()
    adap.expects(:create_sync_group_of_user_operation)
      .with({"Domain Users" => {:gidnumber => 513}, "Domain Admins" => {:gidnumber => 512}}, {"Domain Users" => nil}, "foo")
      .returns({"cn=Domain Admins,#{LDAP_GROUP_BASE}" => [[:add, :memberuid, "foo"]]})
    adap.expects(:do_sync_group_of_user_operation)
      .with({"cn=Domain Admins,#{LDAP_GROUP_BASE}" => [[:add, :memberuid, "foo"]]})
      .returns({:code => 1, :operations => nil, :message => "Some error from do_sync_group_of_user_operation()"})  # will fail

    ret = adap.sync_group_of_user("foo", 513)
    assert_equal({
      :code => 1,
      :operations => [:modify_group_of_user],
      :message => "Some error from do_sync_group_of_user_operation()"}, ret)
  end
end
