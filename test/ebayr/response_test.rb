# -*- encoding : utf-8 -*-
require 'test_helper'
require 'ostruct'

module Ebayr
  class ResponseTest < Test::Unit::TestCase
    def test_response_is_autoloaded
      assert_nothing_raised "Failed to autoload Response! (path = #{$:})" do
        Response
      end
    end

    def test_response_has_the_data_from_the_response
      xml = "<GetSomethingResponse><Foo>Bar</Foo></GetSomethingResponse>"
      response = Response.new(OpenStruct.new(:command => 'GetSomething'), OpenStruct.new(:body => xml))
      assert_equal 'Bar', response['Foo']
      assert_equal 'Bar', response.foo
    end

    def test_response_deals_with_ebay
      xml = "<GeteBayResponse><eBayFoo>Bar</eBayFoo></GeteBayResponse>"
      response = Response.new(OpenStruct.new(:command => 'GeteBay'), OpenStruct.new(:body => xml))
      assert_equal 'Bar', response.ebay_foo
    end

    def test_response_can_be_nested
      xml = <<-XML
        <GetOrdersResponse>
          <OrdersArray>
            <Order>
              <OrderID>1</OrderID>
            </Order>
            <Order>
              <OrderID>2</OrderID>
            </Order>
            <Order>
              <OrderID>3</OrderID>
            </Order>
          </OrdersArray>
        </GetOrdersResponse>
      XML
      response = Response.new(OpenStruct.new(:command => 'GetOrders'), OpenStruct.new(:body => xml))
      assert_kind_of Hash, response.orders_array
      assert_equal "1", response.orders_array.order[0].order_id
      assert_equal "2", response.orders_array.order[1].order_id
      assert_equal "3", response.orders_array.order[2].order_id
    end
  end
end
