# -*- encoding : utf-8 -*-
require 'test_helper'
require 'ostruct'

class Ebayr::ResponseTest < Test::Unit::TestCase
  def test_response_is_autoloaded
    assert_nothing_raised "Failed to autoload Response! (path = #{$:})" do
      Ebayr::Response
    end
  end

  def test_response_knows_the_command_from_the_request
    response = Ebayr::Response.new(OpenStruct.new(:command => 'GetSomething'), nil)
    assert_equal 'GetSomething', response.command
  end

  def test_response_has_the_data_from_the_response
    xml = "<GetSomethingResponse><Foo>Bar</Foo></GetSomethingResponse>"
    response = Ebayr::Response.new(OpenStruct.new(:command => 'GetSomething'), OpenStruct.new(:body => xml))
    assert_equal 'Bar', response['Foo']
    assert_equal 'Bar', response.Foo
  end
end
