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

    def test_corrupted_array_ends_with_comma
      parser = new_parser '["foo",'
      r = parser.parse.result
      assert_equal(['foo'], r)
    end

    def test_corrupted_object_ends_with_opening_square_bracket
      parser = new_parser '["foo",['
      r = parser.parse.result
      assert_equal(['foo', []], r)
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

    def test_corrupted_object
      parser = new_parser '{"foo":true,"bar":fals'
      r = parser.parse.result
      assert_equal({ 'foo' => true }, r)
    end

    def test_corrupted_object_first_value
      parser = new_parser '{"foo":tru'
      r = parser.parse.result
      assert_equal({}, r)
    end

    def test_corrupted_number_in_object
      parser = new_parser '{"foo":13.5,"bar":1'
      r = parser.parse.result
      assert_equal({ 'foo' => 13.5 }, r)
    end

    def test_does_not_touch_uncorrupted_number_in_object
      parser = new_parser '{"foo":13.5,"bar":1}'
      r = parser.parse.result
      assert_equal({ 'foo' => 13.5, 'bar' => 1 }, r)
    end

    def test_corrupted_value_in_nested_object
      parser = new_parser '{"foo":13.5,"bar":{"baz":fals'
      r = parser.parse.result
      assert_equal({ "foo" => 13.5, "bar" => {} }, r)
    end

    def test_corrupted_object_key
      parser = new_parser '{"foo":true,"ba'
      r = parser.parse.result
      assert_equal({ 'foo' => true }, r)
    end

    def test_corrupted_object_ends_with_complete_key
      parser = new_parser '{"foo":true,"bar"'
      r = parser.parse.result
      assert_equal({ 'foo' => true }, r)
    end

    def test_corrupted_object_ends_with_colon
      parser = new_parser '{"foo":true,"bar":'
      r = parser.parse.result
      assert_equal({ 'foo' => true }, r)
    end

    def test_corrupted_object_ends_with_comma
      parser = new_parser '{"foo":true,'
      r = parser.parse.result
      assert_equal({ 'foo' => true }, r)
    end

    def test_corrupted_object_ends_with_opening_curly
      parser = new_parser '{"foo":{'
      r = parser.parse.result
      assert_equal({ 'foo' => {} }, r)
    end

    def test_key_without_value_throws_error
      parser = new_parser '{"foo":}'
      assert_raises(Racc::ParseError) do
        parser.parse.result
      end
    end

    def new_parser string
      tokenizer = Tokenizer.new StringIO.new string
      Parser.new tokenizer
    end
  end
end
