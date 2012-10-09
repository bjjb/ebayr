# -*- encoding : utf-8 -*-
module Ebayr #:nodoc:
  # Encapsulates a request which is sent to the eBay Trading API.
  class Request < Net::HTTP::Post
    include Ebayr

    # Make a new call. The URI used will be that of Ebayr::uri, unless
    # overridden here (same for auth_token, site_id and compatability_level).
    def initialize(call, options = {})
      @call = self.class.camelize(call.to_s)
      @uri = options.delete(:uri) || self.uri
      @uri = URI.parse(@uri) unless @uri.is_a? URI
      @auth_token = (options.delete(:auth_token) || self.auth_token).to_s
      @site_id = (options.delete(:site_id) || self.site_id).to_s
      @compatability_level = (options.delete(:compatability_level) || self.compatability_level).to_s
      # Remaining options are converted and used as input to the call
      @input = self.class.serialize_input(options)
      super(@uri.path, headers)
    end

    # Gets the path to which this request will be posted
    def path
      @uri.path
    end

    # Gets the headers that will be sent with this request.
    def headers
      {
        'X-EBAY-API-COMPATIBILITY-LEVEL' => @compatability_level.to_s,
        'X-EBAY-API-DEV-NAME' => @dev_id.to_s,
        'X-EBAY-API-APP-NAME' => @app_id.to_s,
        'X-EBAY-API-CERT-NAME' => @cert_id.to_s,
        'X-EBAY-API-CALL-NAME' => @call.to_s,
        'X-EBAY-API-SITEID' => @site_id.to_s,
        'Content-Type' => 'text/xml'
      }
    end

    # Gets the body of this request (which is XML)
    def body
      <<-XML
        <?xml version="1.0" encoding="utf-8"?>
        <#{@call}Request xmlns="urn:ebay:apis:eBLBaseComponents">
          <RequesterCredentials>
            <eBayAuthToken>#{@auth_token}</eBayAuthToken>
          </RequesterCredentials>
          #{self.class.xml(@input)}
        </#{@call}Request>
      XML
    end

    # Sends this request, using its own HTTP connection.
    def send
      response = http.start { |h| h.request(self) }
      @response = Response.new(response, self)
    end

    # A very, very simple XML serializer.
    #
    #     Ebayr.xml("Hello!")       # => "Hello!"
    #     Ebayr.xml({:foo=>"Bar"})  # => <foo>Bar</foo>
    def self.xml(structure)
      case structure
        when Hash then structure.map { |k, v| "<#{k.to_s}>#{xml(v)}</#{k.to_s}>" }.join
        when Array then structure.map { |v| xml(v) }
        else structure.to_s
      end
    end

    # Prepares a hash of arguments for input to an eBay Trading API XML call.
    # * Times are converted to ISO 8601 format
    def self.serialize_input(args)
      result = {}
      args.each do |k, v|
        result[k] = case v
          when Time then v.to_time.utc.iso8601
          else v
        end
      end
      result
    end

    # Converts a call like get_ebay_offical_time to GeteBayOfficialTime
    def self.camelize(string)
      string = string.to_s
      return string unless string == string.downcase
      string.split('_').map(&:capitalize).join.gsub('Ebay', 'eBay')
    end

    # Gets a (cached) HTTP connection for this request.
    def http
      return @http if defined? @http
      @http = Net::HTTP.new(@uri.host, @uri.port)
      if @uri.port == 443
        @http.use_ssl = true
        @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      @http
    end
  end
end
