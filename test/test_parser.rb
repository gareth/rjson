require 'minitest/autorun'
require 'rjson/parser'
require 'rjson/tokenizer'
require 'rjson/stream_tokenizer'
require 'stringio'

module RJSON
  class TestParser < MiniTest::Unit::TestCase
    def test_array
      parser = new_parser '["foo",null,true]'
      r = parser.parse.result
      assert_equal(['foo', nil, true], r)
    end

    def test_corrupted_array
      parser = new_parser '["foo",fals'
      r = parser.parse.result
      assert_equal(['foo'], r)
    end

    def test_corrupted_number_in_array
      parser = new_parser '["foo",1'
      r = parser.parse.result
      assert_equal(['foo'], r)
    end

    def test_does_not_touch_uncorrupted_number_in_array
      parser = new_parser '["foo",1]'
      r = parser.parse.result
      assert_equal(['foo',1], r)
    end

    def test_corrupted_value_in_nested_array
      parser = new_parser '["foo",[10.3,["bar",fals'
      r = parser.parse.result
      assert_equal(['foo',[10.3,['bar']]], r)
    end

    def test_object
      parser = new_parser '{"foo":{"bar":null}}'
      r = parser.parse.result
      assert_equal({ 'foo' => { 'bar' => nil }}, r)
    end

    def new_parser string
      tokenizer = Tokenizer.new StringIO.new string
      Parser.new tokenizer
    end
  end
end
