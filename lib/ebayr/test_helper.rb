# -*- encoding : utf-8 -*-
module Ebayr
  module TestHelper
    @@success = Ebayr.xml(:Ack => "Success")

    def self.included(mod)
      begin
        require 'webmock' unless const_defined?(:WebMock)
      rescue LoadError
        throw "Couldn't load webmock! Is it in your Gemfile?"
      end
    end

    # Allows you to stub out the calls within the given block. For example:
    # 
    #   def test_something
    #     stub_ebay_call!(:GeteBayOffficialTime, :Timestamp => "Yo") do
    #       assert Ebayr.call(:GeteBayOfficialTime) # => stubbed call
    #     end
    #   end
    #
    # This method is deprecated, and will be removed in a future release.
    def stub_ebay_call!(call, content, &block)
      puts <<DEPRECATION
stub_ebay_call! is deprecated, and will be removed in a future release. Please
use Ruby techniques to stub eBay calls your way. See the wiki for details.
DEPRECATION
      content = Ebayr.xml(content) unless content.is_a?(String)
      net_connect_allowed = WebMock.net_connect_allowed?
      WebMock.disable_net_connect!
      body = <<-XML
        <#{call}Response>
          #{Ebayr.xml(:Ack => "Success")}
          #{content}
        </#{call}Response>
      XML
      stub = WebMock.stub_request(:any, Ebayr.uri).to_return(:body => body)
      yield
      WebMock.remove_request_stub stub
      WebMock.allow_net_connect! if net_connect_allowed
    end
  end
end
