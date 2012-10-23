# -*- encoding : utf-8 -*-
require 'hipsterhash'

module Ebayr #:nodoc:
  # A response to an Ebayr::Request.
  class Response
    def initialize(request, response)
      @request, @response = request, response
    end    

    def command
      @request.command
    end

    def xml
      @response.body
    end

    def object
      @object ||= Record.new(deserialize["#{command}Response"])
    end

    def deserialize
      self.class.deserialize(xml)
    end

    def [](key)
      object[key]
    end

    def method_missing(sym, *args, &block)
      object[sym] || super
    end

    def self.deserialize(xml)
      HipsterHash.from_xml(xml)
    end
  end
end
