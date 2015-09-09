require 'nokogiri'

# -*- encoding : utf-8 -*-
module Ebayr #:nodoc:
  # A response to an Ebayr::Request.
  class Response < Record
    def initialize(request, response)
      @request = request
      @command = @request.command if @request
      @response = response
      @body = response.body if @response
      if @body
        doc = Nokogiri::XML(@body)
        hash = Hash.from_xml(doc.to_s)
      end
      response_data = hash["#{@command}Response"] if hash
      super(response_data) if response_data
    end
  end
end
