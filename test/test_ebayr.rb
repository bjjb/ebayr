require 'test/unit'
require 'ebayr'

class TestEbayr < Test::Unit::TestCase
  # If this passes without an exception, then we're ok.
  def test_sanity
    result = Ebayr.call(:GeteBayOfficialTime)
    puts "The eBay time is: #{result['Timestamp']}"
  end
end
