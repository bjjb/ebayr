# -*- encoding : utf-8 -*-
module Ebayr #:nodoc:
  # A response to an Ebayr::Request.
  class Response < Record
    def initialize(request, response)
      @request = request
      @command = @request.command if @request
      @response = response
      @body = response.body if @response
      hash = self.class.from_xml(@body) if @body
      response_data = hash["#{@command}Response"] if hash
      super(response_data) if response_data
    end
  end
end
