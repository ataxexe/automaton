require 'automaton'

require "#{File.dirname(__FILE__)}/test_helper"

class ConnectionTest < Test::Unit::TestCase

  def setup
    @connection = {}
    @connection.extend Connection
  end

  def test_normal_behaviour
    @connection.add 'a', 1
    @connection.add 'b', 2
    @connection.add 'c', 3

    assert_equal(1, @connection.get('a')[:state])
    assert_equal('a', @connection.get('a')[:value])

    assert_equal(2, @connection.get('b')[:state])
    assert_equal('b', @connection.get('b')[:value])

    assert_equal(3, @connection.get('c')[:state])
    assert_equal('c', @connection.get('c')[:value])
  end

  def test_overloaded
    @connection.add 'a', 1
    @connection.add 'a', 2
    @connection.add 'a', 3

    assert(!@connection.has_empty?)
    assert @connection.get('a').is_a?(Array)
    assert_equal(3, @connection.get('a').size)
  end

  def test_empty_connection
    @connection.add '', 1
    @connection.add 'a', 2

    assert @connection.has_empty?
    assert @connection.get('a').is_a?(Array)
    assert_equal(2, @connection.get('a').size)
  end

  def test_empty_and_overloaded_connection
    @connection.add '', 1
    @connection.add 'a', 2
    @connection.add 'a', 3

    assert @connection.has_empty?
    assert @connection.get('a').is_a?(Array)
    assert_equal(3, @connection.get('a').size)
  end

  def test_overloaded_empty_connection
    @connection.add '', 1
    @connection.add '', 2
    @connection.add 'a', 3

    assert @connection.has_empty?
    assert @connection.get('a').is_a?(Array)
    assert_equal(3, @connection.get('a').size)
  end

end
