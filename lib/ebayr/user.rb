# -*- encoding : utf-8 -*-
module Ebayr
  module User
    # Shorthand for call(call, arguments.merge(:auth_token => this.ebay_token))
    # Allows objects which mix in this module to use their own token.
    def ebay_call(call, arguments = {})
      raise "#{self} has no eBay token" unless ebay_token
      Ebayr.call(call, arguments.merge(:auth_token => ebay_token))
    end

    # Gets the user's data
    def get_ebay_data
      ebay_call(:GetUser)
    end
  end
end
