require 'test/unit'

module TestHelper

  def assert_accept fa, *values
    values.each do |value|
      assert fa.accept?(value), "'#{value}' not accepted!"
      assert(!fa.reject?(value), "'#{value}' rejected!")
    end
  end

  def assert_reject fa, *values
    values.each do |value|
      assert fa.reject?(value), "'#{value}' not rejected!"
      assert(!fa.accept?(value), "'#{value}' accepted!")
    end
  end

  def read_test_file filename
    File.open("#{File.dirname(__FILE__)}/#{filename}") {|f| f.read}
  end

end

class Test::Unit::TestCase
  include TestHelper
end
