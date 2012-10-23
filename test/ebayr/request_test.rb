# -*- encoding : utf-8 -*-
require 'test_helper'

class Ebayr::RequestTest < Test::Unit::TestCase
  def test_request_is_autoloaded
    assert_nothing_raised "Failed to autoload Request! (path = #{$:})" do
      Ebayr::Request
    end
  end

  def test_times_are_converted_when_serializing_input
    result = Ebayr::Request.serialize_input({ "Time" => Time.utc(2010, 'oct', 31, 03, 15) })
    assert_equal "2010-10-31T03:15:00Z", result['Time']
  end

  def test_request_uri
    assert Ebayr::Request.uri
    assert_equal Ebayr.uri, Ebayr::Request.uri
    assert_equal Ebayr.uri, Ebayr::Request.new(:Blah).uri
  end
end
