require "test_helper"

class ModAdNtLdapTest < Minitest::Test
  #def test_that_it_has_a_version_number
  #  refute_nil ::ModAdNtLdap::VERSION
  #end

  def test_it_does_something_useful
    adnt = AdNtLdap.new({:foo => "bar"})
    puts adnt.display()
  end

  def test_raise_error_if_params_is_nil
    exception = assert_raises RuntimeError do
      AdNtLdap.new(nil)
    end
    puts exception.message
    assert_equal(exception.message, "Initialize AdNtLdap was failed. params must not be nil")
  end
end
