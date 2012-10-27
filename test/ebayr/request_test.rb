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
  end
end
