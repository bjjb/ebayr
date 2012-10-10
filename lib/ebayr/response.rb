# -*- encoding : utf-8 -*-
require 'ostruct'
module Ebayr #:nodoc:
  # A response to an Ebayr::Request.
  class Response < OpenStruct
    class << self
      def new(response, request)
        case response
        when Net::HTTPSuccess
          data = Hash.from_xml(response.body)
          result = data["#{request.command}Response"]
          case result['Ack']
            when 'Success' then Success.new(data, request)
            when 'Failure' then Failure.new(data, request)
            when 'PartialFailure' then PartialFailure.new(data, request)
            when nil then raise "No Ack in response : #{data}"
            else raise "Unexpected Ack (#{data['Ack']}) in response"
          end
        else
          Error.new(response, request)
        end
      end
    end

    def initialize(data, request)
      super(data)
      @request = request
      normalize! if Ebayr.normalize_response?
    end

    class Success < Response
    end

    class Failure < Response
    end

    class PartialFailure < Response
    end

    class Error < Exception
      def initialize(response, request)
        @response, @request = response, request
      end

      def to_s
        "#{@request} -> #{@response.class}"
      end
    end
  end
end
