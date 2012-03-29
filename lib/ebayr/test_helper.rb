module Ebayr
  module TestHelper
    @@success = Ebayr.xml(:Ack => "Success")

    def self.included(mod)
      begin
        require 'fakeweb' unless const_defined?(:FakeWeb)
      rescue LoadError
        throw "Couldn't load fakeweb! Is it in your Gemfile?"
      end
    end

    # Allows you to stub out the calls within the given block. For example:
    # 
    #   def test_something
    #     stub_ebay_call!(:GeteBayOffficialTime, :Timestamp => "Yo") do
    #       assert Ebayr.call(:GeteBayOfficialTime) # => stubbed call
    #     end
    #   end
    def stub_ebay_call!(call, content, &block)
      content = Ebayr.xml(content) unless content.is_a?(String)
      _allow_net_connect_ = FakeWeb.allow_net_connect?
      FakeWeb.allow_net_connect = false
      body = <<-XML
        <#{call}Response>
          #{Ebayr.xml(:Ack => "Success")}
          #{content}
        </#{call}Response>
      XML
      FakeWeb.register_uri( :any, Ebayr.uri, :body => body)
      yield
      FakeWeb.clean_registry
      FakeWeb.allow_net_connect = _allow_net_connect_
    end

  end
end
