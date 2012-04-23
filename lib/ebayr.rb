# -*- encoding : utf-8 -*-
require 'net/https'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/hash/conversions'
require 'active_support/buffered_logger'

module Ebayr
  autoload :User, 'ebayr/user'
  mattr_accessor :dev_id,
                 :app_id,
                 :cert_id,
                 :ru_name,
                 :auth_token,
                 :sandbox,
                 :authorization_callback_url,
                 :callbacks,
                 :site_id,
                 :compatability_level,
                 :logger

  @@logger ||= if defined?(Rails) 
    Rails.logger
  else
    ActiveSupport::BufferedLogger.new(STDOUT) 
  end

  %W(/etc/ebayrc.conf /usr/local/etc/ebayrc.conf ~/.ebayrc.conf ./.ebayrc.conf).each do |path|
    load path if File.exists?(path = File.expand_path(path))
  end


  @@site_id             ||= 0   # US
  @@compatability_level ||= 745

  def self.sandbox?
    !!sandbox
  end

  # Gets either ebay.com/ws or sandbox.ebay.com/ws, as appropriate, with
  # "service" prepended. E.g.
  #
  #     Ebayr.uri_prefix("blah")  # => https://blah.ebay.com/ws
  #     Ebayr.uri_prefix          # => https://api.ebay.com/ws
  def self.uri_prefix(service = "api")
    "https://#{service}#{sandbox ? ".sandbox" : ""}.ebay.com/ws"
  end

  # Gets the URI used for API calls (as a URI object)
  def self.uri(*args)
    URI::parse("#{uri_prefix(*args)}/api.dll")
  end

  # Gets the URI for eBay authorization/login. The session_id should be obtained
  # via an API call to GetSessionID (be sure to use the right ru_name), and the
  # ru_params can contain anything (they will be passed back to your app in the
  # redirect from eBay upon successful login and authorization).
  def self.authorization_uri(session_id, ru_params = {})
    ruparams = CGI::escape(ru_params.map { |k, v| "#{k}=#{v}" }.join("&"))
    URI::parse("#{uri_prefix("signin")}/eBayISAPI.dll?SignIn&RuName=#{ru_name}&SessId=#{session_id}&ruparams=#{ruparams}")
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

  # Make an eBay call (symbol or string). You can pass in these arguments:
  #
  # auth_token:: to use a user's token instead of the general token
  # site_id:: to use a specific eBay site (default is 0, which is US ebay.com)
  # compatability_level:: declare another eBay Trading API compatability_level
  #
  # All other arguments are passed into the API call, and may be nested.
  #
  # Remember, case matters.
  #
  #     call(:GeteBayOfficialTime)
  #
  # The response is a Hash of the response, deserialized from the XML by
  # ActiveSupport's XML deserializer.
  def self.call(call, arguments = {})
    call = call.to_s

    auth_token = arguments.delete(:auth_token) || self.auth_token.to_s
    site_id = arguments.delete(:site_id) || self.site_id.to_s
    compatability_level = arguments.delete(:compatability_level) || self.compatability_level.to_s
    arguments = process_args(arguments)

    headers = {
      'X-EBAY-API-COMPATIBILITY-LEVEL' => compatability_level.to_s,
      'X-EBAY-API-DEV-NAME' => dev_id.to_s,
      'X-EBAY-API-APP-NAME' => app_id.to_s,
      'X-EBAY-API-CERT-NAME' => cert_id.to_s,
      'X-EBAY-API-CALL-NAME' => call.to_s,
      'X-EBAY-API-SITEID' => site_id.to_s,
      'Content-Type' => 'text/xml'
    }

    xml = xml(arguments)

    xml = <<-XML
      <?xml version="1.0" encoding="utf-8"?>
      <#{call}Request xmlns="urn:ebay:apis:eBLBaseComponents">
        <RequesterCredentials>
          <eBayAuthToken>#{auth_token}</eBayAuthToken>
        </RequesterCredentials>
        #{xml}
      </#{call}Request>
    XML

    request = Net::HTTP::Post.new(uri.path, headers)

    request.body = xml.to_s

    http = Net::HTTP.new(uri.host, uri.port)

    if uri.port == 443
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    response = http.start { |http| http.request(request) }

    if callbacks
      callbacks.each do |callback|
        if callback.is_a?(Symbol)
          send(callback, request, response)
        elsif callback.respond_to?(:call)
          callback.call(request, response)
        else
          throw Error.new("Invalid callback: #{callback.to_s}")
        end
      end
    end

    case response
    when Net::HTTPSuccess 
      result = Hash.from_xml(response.body)["#{call}Response"]
      unless result
        raise Exception.new("No #{call}Response in response", request, response)
      end
      case result['Ack']
      when 'Success'
        return result
      when 'Warning'
        @@logger.warn(result['Errors'].inspect)
        return result
      else
        raise Error.new(result['Errors'], request, response)
      end
      return result
    else
      raise Exception.new("Unexpected response from server", request, response)
    end
  end

  def self.process_args(args)
    result = {}
    args.each do |k, v|
      result[k] = case v
        when Date, Time then v.to_time.utc.iso8601
        else v
      end
    end
    result
  end

  class Exception < ::Exception
    attr_reader :request, :response
    def initialize(message, request, response)
      super message
      @request, @response = request, response
    end
  end

  class Error < Exception
    attr_reader :request, :response, :errors
    def initialize(errors, request, response)
      @errors, @request, @response = errors, request, response
      super
    end
    
    def to_s
      [@errors].flatten.map { |e| "<#{e['LongMessage']}>" }.join(", ")
    end
  end
end
