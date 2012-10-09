# -*- encoding : utf-8 -*-
require 'test/unit'
require File.expand_path("../../../lib/ebayr", __FILE__)

class Response < Test::Unit::TestCase
  def test_response_is_autoloaded
    assert_nothing_raised "Failed to autoload Request! (path = #{$:})" do
      Ebayr::Response
    end
  end
end
