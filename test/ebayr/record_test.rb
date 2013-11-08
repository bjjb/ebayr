# -*- encoding : utf-8 -*-
require 'test_helper'
require 'ebayr/record'

module Ebayr
  class RecordTest < MiniTest::Unit::TestCase
    def test_lookup_is_case_insensitive
      record = Record.new('Foo' => 'Bar')
      assert_equal 'Bar', record['Foo']
    end

    def test_records_are_nested
      record = Record.new(:Foo => { "Bar" => "Baz" })
      assert_equal "Baz", record.foo.bar

      record = Record.new('Foo' => { 'Bars' => [{ 'Value' => 1 }, { 'Value' => 2 }] })
      assert_equal 1, record.foo.bars[0].value
      assert_equal 2, record.foo.bars[1].value
    end
  end
end
