require "test_helper"

class ModAdapTest < Minitest::Test

  def test_sync_user_should_failed_if_ldap_search_from_ad_was_failed
    mock                                = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result        = mock()

    # @ad_client.search()
    mock[:ad_client].expects(:search)
      .with(:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
      .yields({:objectclass => ["top", "person"], :cn => "ad"})

    # @ad_client.get_operation_result.code
    mock_ad_get_operation_result.expects(:code).returns(1)
    # @ldap_client.get_operation_result.error_message of @ldap_client.delete
    mock_ad_get_operation_result.expects(:error_message).returns("Some error")
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result).times(2)

    # Testing from here
    adap = Adap.new({
      :ad_host              => "localhost",
      :ad_binddn            => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_basedn       => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_basedn      => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password          => "ad_secret",
      :ldap_host            => "ldap_server",
      :ldap_binddn          => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_basedn     => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_basedn    => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password        => "ldap_secret"
    })
    adap.expects(:get_ad_user_dn).returns("CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
    adap.expects(:get_ldap_user_dn).returns("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
    ret = adap.sync_user("foo", nil)
    assert_equal({:code => 1, :operations => nil, :message => "Failed to get a user CN=foo,CN=Users,DC=mysite,DC=example,DC=com from AD - Some error"}, ret)
  end

  def test_sync_user_should_failed_if_ldap_search_from_ldap_was_failed
    mock                                = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result        = mock()
    mock_ldap_get_operation_result      = mock()

    # @ad_client.search()
    mock[:ad_client].expects(:search)
      .with(:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
      .yields({:objectclass => ["top", "person"], :cn => "ad"})

    mock[:ldap_client].expects(:search)
      .with(:base => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
      .yields({:objectclass => ["top", "person"], :cn => "ldap"})

    # @ad_client.get_operation_result.code
    mock_ad_get_operation_result.expects(:code).returns(0)
    # @ad_client.get_operation_result
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    # @ldap_client.get_operation_result.code
    mock_ldap_get_operation_result.expects(:code).returns(1)
    mock_ldap_get_operation_result.expects(:error_message).returns("Some error")
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result).times(2)

    # Testing from here
    adap = Adap.new({
      :ad_host              => "localhost",
      :ad_binddn            => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_basedn       => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_basedn      => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password          => "ad_secret",
      :ldap_host            => "ldap_server",
      :ldap_binddn          => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_basedn     => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_basedn    => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password        => "ldap_secret"
    })
    adap.expects(:get_ad_user_dn).returns("CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
    adap.expects(:get_ldap_user_dn).returns("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
    ret = adap.sync_user("foo", nil)
    assert_equal({:code => 1, :operations => nil, :message => "Failed to get a user uid=foo,ou=Users,dc=mysite,dc=example,dc=com from LDAP - Some error"}, ret)
  end

  def test_sync_user_should_success_if_add_user_returns_success
    mock                                = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result        = mock()
    mock_ldap_get_operation_result      = mock()

    # @ad_client.search()
    mock[:ad_client].expects(:search)
      .with(:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
      .yields({:objectclass => ["top", "person"], :cn => "ad"})

    mock[:ldap_client].expects(:search)
      .with(:base => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
      .yields(nil)

    # @ad_client.get_operation_result.code
    mock_ad_get_operation_result.expects(:code).returns(0)
    # @ad_client.get_operation_result
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    # @ldap_client.get_operation_result.code
    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = Adap.new({
      :ad_host              => "localhost",
      :ad_binddn            => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_basedn       => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_basedn      => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password          => "ad_secret",
      :ldap_host            => "ldap_server",
      :ldap_binddn          => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_basedn     => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_basedn    => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password        => "ldap_secret"
    })
    adap.expects(:get_ad_user_dn).returns("CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
    adap.expects(:get_ldap_user_dn).returns("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
    adap.expects(:get_password_hash).with("foo", "secret").returns("{SSHA}secret")
    adap.expects(:add_user)
      .with("uid=foo,ou=Users,dc=mysite,dc=example,dc=com", {:objectclass => ["top", "person"], :cn => "ad"}, "{SSHA}secret")
      .returns({:code => 0, :operations => [:add_user], :message => "Success add_user"})
    adap.expects(:get_primary_gidnumber)
      .with({:objectclass => ["top", "person"], :cn => "ad"})
      .returns(513)
    adap.expects(:sync_group_of_user)
      .with("foo", 513)
      .returns({:code => 0, :operations => [:some_group_of_user_operation], :message => nil})

    ret = adap.sync_user("foo", "secret")
    assert_equal({:code => 0, :operations => [:add_user, :some_group_of_user_operation], :message => nil}, ret)
  end

  def test_sync_user_should_success_if_delete_user_returns_success
    mock                                = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result        = mock()
    mock_ldap_get_operation_result      = mock()

    # @ad_client.search()
    mock[:ad_client].expects(:search)
      .with(:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
      .yields(nil)

    mock[:ldap_client].expects(:search)
      .with(:base => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
      .yields({:objectclass => ["top", "person"], :cn => "ad"})

    ## ad_client == nil and ldap_client != nil -> delete_user

    # @ad_client.get_operation_result.code
    mock_ad_get_operation_result.expects(:code).returns(0)
    # @ad_client.get_operation_result
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    # @ldap_client.get_operation_result.code
    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = Adap.new({
      :ad_host              => "localhost",
      :ad_binddn            => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_basedn       => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_basedn      => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password          => "ad_secret",
      :ldap_host            => "ldap_server",
      :ldap_binddn          => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_basedn     => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_basedn    => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password        => "ldap_secret"
    })
    adap.expects(:get_ad_user_dn).returns("CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
    adap.expects(:get_ldap_user_dn).returns("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
    adap.expects(:delete_user)
      .with("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
      .returns({:code => 0, :operations => [:delete_user], :message => "Success delete_user"})
    adap.expects(:get_primary_gidnumber).with(nil).returns(nil)
    adap.expects(:sync_group_of_user)
      .with("foo", nil)
      .returns({:code => 0, :operations => [:some_group_of_user_operation], :message => nil})

    ret = adap.sync_user("foo", "secret")
    assert_equal({:code => 0, :operations => [:delete_user, :some_group_of_user_operation], :message => nil}, ret)
  end

  def test_sync_user_should_success_if_modify_user_returns_success
    mock                                = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result        = mock()
    mock_ldap_get_operation_result      = mock()

    # @ad_client.search()
    mock[:ad_client].expects(:search)
      .with(:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
      .yields({:objectclass => ["top", "person"], :cn => "ad"})

    mock[:ldap_client].expects(:search)
      .with(:base => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
      .yields({:objectclass => ["top", "person"], :cn => "ldap"})

    # @ad_client.get_operation_result.code
    mock_ad_get_operation_result.expects(:code).returns(0)
    # @ad_client.get_operation_result
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    # @ldap_client.get_operation_result.code
    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = Adap.new({
      :ad_host              => "localhost",
      :ad_binddn            => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_basedn       => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_basedn      => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password          => "ad_secret",
      :ldap_host            => "ldap_server",
      :ldap_binddn          => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_basedn     => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_basedn    => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password        => "ldap_secret"
    })
    adap.expects(:get_ad_user_dn).returns("CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
    adap.expects(:get_ldap_user_dn).returns("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
    adap.expects(:get_password_hash).with("foo", "secret").returns("{SSHA}secret")
    adap.expects(:modify_user)
      .with("uid=foo,ou=Users,dc=mysite,dc=example,dc=com", {:objectclass => ["top", "person"], :cn => "ad"}, {:objectclass => ["top", "person"], :cn => "ldap"}, "{SSHA}secret")
      .returns({:code => 0, :operations => [:modify_user], :message => "Success add_user"})
    adap.expects(:get_primary_gidnumber)
      .with({:objectclass => ["top", "person"], :cn => "ad"})
      .returns(513)
    adap.expects(:sync_group_of_user)
      .with("foo", 513)
      .returns({:code => 0, :operations => [:some_group_of_user_operation], :message => nil})

    ret = adap.sync_user("foo", "secret")
    assert_equal({:code => 0, :operations => [:modify_user, :some_group_of_user_operation], :message => nil}, ret)
  end

  def test_sync_user_should_success_if_modify_user_is_called_and_password_hash_algorithm_is_ssha_and_password_is_nil
    mock                                = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result        = mock()
    mock_ldap_get_operation_result      = mock()

    # @ad_client.search()
    mock[:ad_client].expects(:search)
      .with(:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
      .yields({:objectclass => ["top", "person"], :cn => "ad"})

    mock[:ldap_client].expects(:search)
      .with(:base => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
      .yields({:objectclass => ["top", "person"], :cn => "ldap"})

    # @ad_client.get_operation_result.code
    mock_ad_get_operation_result.expects(:code).returns(0)
    # @ad_client.get_operation_result
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    # @ldap_client.get_operation_result.code
    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = Adap.new({
      :ad_host              => "localhost",
      :ad_binddn            => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_basedn       => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_basedn      => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password          => "ad_secret",
      :ldap_host            => "ldap_server",
      :ldap_binddn          => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_basedn     => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_basedn    => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password        => "ldap_secret"
    })
    adap.expects(:get_ad_user_dn).returns("CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
    adap.expects(:get_ldap_user_dn).returns("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
    adap.expects(:modify_user)
      .with("uid=foo,ou=Users,dc=mysite,dc=example,dc=com", {:objectclass => ["top", "person"], :cn => "ad"}, {:objectclass => ["top", "person"], :cn => "ldap"}, nil)
      .returns({:code => 0, :operations => [:modify_user], :message => "Success add_user"})
    adap.expects(:get_primary_gidnumber)
      .with({:objectclass => ["top", "person"], :cn => "ad"})
      .returns(513)
    adap.expects(:sync_group_of_user)
      .with("foo", 513)
      .returns({:code => 0, :operations => [:some_group_of_user_operation], :message => nil})

    ret = adap.sync_user("foo", nil)
    assert_equal({:code => 0, :operations => [:modify_user, :some_group_of_user_operation], :message => nil}, ret)
  end

  def test_sync_user_should_error_if_ad_entry_and_ldap_entry_does_not_existed
    mock                                = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result        = mock()
    mock_ldap_get_operation_result      = mock()

    # @ad_client.search()
    mock[:ad_client].expects(:search)
      .with(:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
      .yields(nil)

    mock[:ldap_client].expects(:search)
      .with(:base => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
      .yields(nil)

    # @ad_client.get_operation_result.code
    mock_ad_get_operation_result.expects(:code).returns(0)
    # @ad_client.get_operation_result
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    # @ldap_client.get_operation_result.code
    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = Adap.new({
      :ad_host              => "localhost",
      :ad_binddn            => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_basedn       => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_basedn      => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password          => "ad_secret",
      :ldap_host            => "ldap_server",
      :ldap_binddn          => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_basedn     => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_basedn    => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password        => "ldap_secret"
    })
    adap.expects(:get_ad_user_dn).returns("CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
    adap.expects(:get_ldap_user_dn).returns("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")

    ret = adap.sync_user("foo", "secret")
    assert_equal({:code => 0, :operations => nil, :message => "There are not any data of foo to sync."}, ret)
  end

  def test_sync_user_should_success_if_ad_query_returns_32_and_ldap_query_returns_0
    mock                                = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result        = mock()
    mock_ldap_get_operation_result      = mock()

    # @ad_client.search()
    mock[:ad_client].expects(:search)
      .with(:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
      .yields(nil)

    mock[:ldap_client].expects(:search)
      .with(:base => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
      .yields(nil)

    ## ad_client == nil and ldap_client != nil -> delete_user

    # @ad_client.get_operation_result.code. Return 32 means that the object does not exist.
    mock_ad_get_operation_result.expects(:code).returns(32)
    # @ad_client.get_operation_result
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    # @ldap_client.get_operation_result.code
    mock_ldap_get_operation_result.expects(:code).returns(0)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = Adap.new({
      :ad_host              => "localhost",
      :ad_binddn            => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_basedn       => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_basedn      => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password          => "ad_secret",
      :ldap_host            => "ldap_server",
      :ldap_binddn          => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_basedn     => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_basedn    => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password        => "ldap_secret"
    })
    adap.expects(:get_ad_user_dn).returns("CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
    adap.expects(:get_ldap_user_dn).returns("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")

    ret = adap.sync_user("foo", "secret")
    assert_equal({:code => 0, :operations => nil, :message => "There are not any data of foo to sync."}, ret)
  end

  def test_sync_user_should_success_if_ad_query_returns_0_and_ldap_query_returns_32
    mock                                = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result        = mock()
    mock_ldap_get_operation_result      = mock()

    # @ad_client.search()
    mock[:ad_client].expects(:search)
      .with(:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
      .yields(nil)

    mock[:ldap_client].expects(:search)
      .with(:base => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
      .yields(nil)

    ## ad_client == nil and ldap_client != nil -> delete_user

    # @ad_client.get_operation_result.code
    mock_ad_get_operation_result.expects(:code).returns(0)
    # @ad_client.get_operation_result
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    # @ldap_client.get_operation_result.code
    mock_ldap_get_operation_result.expects(:code).returns(32)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = Adap.new({
      :ad_host              => "localhost",
      :ad_binddn            => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_basedn       => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_basedn      => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password          => "ad_secret",
      :ldap_host            => "ldap_server",
      :ldap_binddn          => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_basedn     => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_basedn    => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password        => "ldap_secret"
    })
    adap.expects(:get_ad_user_dn).returns("CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
    adap.expects(:get_ldap_user_dn).returns("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")

    ret = adap.sync_user("foo", "secret")
    assert_equal({:code => 0, :operations => nil, :message => "There are not any data of foo to sync."}, ret)
  end

  def test_sync_user_should_success_if_ad_query_and_ldap_query_returns_32
    mock                                = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result        = mock()
    mock_ldap_get_operation_result      = mock()

    # @ad_client.search()
    mock[:ad_client].expects(:search)
      .with(:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
      .yields(nil)

    mock[:ldap_client].expects(:search)
      .with(:base => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
      .yields(nil)

    # @ad_client.get_operation_result.code
    mock_ad_get_operation_result.expects(:code).returns(32)
    # @ad_client.get_operation_result
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    # @ldap_client.get_operation_result.code
    mock_ldap_get_operation_result.expects(:code).returns(32)
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = Adap.new({
      :ad_host              => "localhost",
      :ad_binddn            => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_basedn       => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_basedn      => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password          => "ad_secret",
      :ldap_host            => "ldap_server",
      :ldap_binddn          => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_basedn     => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_basedn    => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password        => "ldap_secret"
    })
    adap.expects(:get_ad_user_dn).returns("CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
    adap.expects(:get_ldap_user_dn).returns("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")

    ret = adap.sync_user("foo", "secret")
    assert_equal({:code => 0, :operations => nil, :message => "There are not any data of foo to sync."}, ret)
  end

  def test_sync_user_should_failed_if_sync_group_of_user_returns_error
    mock                                = mock_ad_and_ldap_connections()
    mock_ad_get_operation_result        = mock()
    mock_ldap_get_operation_result      = mock()

    # @ad_client.search()
    mock[:ad_client].expects(:search)
      .with(:base => "CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
      .yields({:objectclass => ["top", "person"], :cn => "ad"})

    mock[:ldap_client].expects(:search)
      .with(:base => "uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
      .yields({:objectclass => ["top", "person"], :cn => "ldap"})

    # @ad_client.get_operation_result.code
    mock_ad_get_operation_result.expects(:code).returns(0)
    # @ad_client.get_operation_result
    mock[:ad_client].expects(:get_operation_result).returns(mock_ad_get_operation_result)

    # @ldap_client.get_operation_result.code
    mock_ldap_get_operation_result.expects(:code).returns(0)
    # @ldap_client.get_operation_result
    mock[:ldap_client].expects(:get_operation_result).returns(mock_ldap_get_operation_result)

    # Testing from here
    adap = Adap.new({
      :ad_host              => "localhost",
      :ad_binddn            => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
      :ad_user_basedn       => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_group_basedn      => "CN=Users,DC=mysite,DC=example,DC=com",
      :ad_password          => "ad_secret",
      :ldap_host            => "ldap_server",
      :ldap_binddn          => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_user_basedn     => "ou=Users,dc=mysite,dc=example,dc=com",
      :ldap_group_basedn    => "ou=Groups,dc=mysite,dc=example,dc=com",
      :ldap_password        => "ldap_secret"
    })
    adap.expects(:get_ad_user_dn).returns("CN=foo,CN=Users,DC=mysite,DC=example,DC=com")
    adap.expects(:get_ldap_user_dn).returns("uid=foo,ou=Users,dc=mysite,dc=example,dc=com")
    adap.expects(:get_password_hash).with("foo", "secret").returns("{SSHA}secret")
    adap.expects(:modify_user)
      .with("uid=foo,ou=Users,dc=mysite,dc=example,dc=com", {:objectclass => ["top", "person"], :cn => "ad"}, {:objectclass => ["top", "person"], :cn => "ldap"}, "{SSHA}secret")
      .returns({:code => 0, :operations => [:modify_user], :message => "Success add_user"})
    adap.expects(:get_primary_gidnumber)
      .with({:objectclass => ["top", "person"], :cn => "ad"})
      .returns(513)
    adap.expects(:sync_group_of_user)
      .with("foo", 513)
      .returns({:code => 1, :operations => [:some_group_of_user_operation], :message => "Some error"})

    ret = adap.sync_user("foo", "secret")
    assert_equal({
      :code => 1,
      :operations => [:modify_user, :some_group_of_user_operation],
      :message => "Syncing a user foo has succeeded but syncing its groups have failed. Message: Some error"
    }, ret)
  end
end
