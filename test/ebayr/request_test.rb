# -*- encoding : utf-8 -*-
require 'test_helper'

module Ebayr
  class RequestTest < Test::Unit::TestCase
    def test_request_is_autoloaded
      assert_nothing_raised "Failed to autoload Request! (path = #{$:})" do
        Request
      end
    end

    def test_times_are_converted_when_serializing_input
      result = Request.serialize_input({ "Time" => Time.utc(2010, 'oct', 31, 03, 15) })
      assert_equal "2010-10-31T03:15:00Z", result['Time']
    end

    def test_request_uri
      assert Request.uri
      assert_equal Ebayr.uri, Request.uri
      assert_equal Ebayr.uri, Request.new(:Blah).uri
    end

    def test_xml_of_a_hash
      expected = '<a><b>123</b></a>'
      assert_equal expected, Request.xml({ :a => { :b => 123 } })
    end

    def test_xml_of_an_array
      expected = '<a>1</a><a>2</a>'
      assert_equal expected, Request.xml([{ :a => 1 }, { :a => 2 }])
    end

    def test_xml_of_a_string
      assert_equal 'boo', Request.xml('boo')
    end

    def test_xml_of_a_number
      assert_equal '1234', Request.xml(1234)
    end

    def test_xml_of_multiple_arguments
      assert_equal '<a>1</a><a><b>1</b><b>2</b></a>',
        Request.xml({ :a => 1 }, { :a => [{:b => 1 }, { :b => 2 }] })
    end
  end
end
