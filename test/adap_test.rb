require "test_helper"

class ModAdapTest < Minitest::Test
  #def test_that_it_has_a_version_number
  #  refute_nil ::ModAdap::VERSION
  #end

  def test_raise_error_if_params_is_nil
    exception = assert_raises RuntimeError do
      Adap.new(nil)
    end
    assert_equal(exception.message, "Initialize Adap was failed. params must not be nil")
  end

  def test_raise_error_if_params_doesnt_have_ad_host
    exception = assert_raises RuntimeError do
      Adap.new({
        :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
        :ad_basedn => "CN=Users,DC=mysite,DC=example,DC=com",
        :nt_host   => "192.168.1.12",
        :nt_binddn => "uid=Administrator,ou=Users,dc=mysite,dc=example,dc=com",
        :nt_basedn => "dc=mysite,dc=example,dc=com"
      })
    end
  end

#  def test_it_does_something_useful
#    adnt = Adap.new({
#      :ad_host => "192.168.1.10",
#      :ad_binddn => "CN=Administrator,CN=Users,DC=mysite,DC=example,DC=com",
#      :ad_basedn => "DC=mysite,DC=example,DC=com",
#    })
#    puts adnt.display()
#  end


end
