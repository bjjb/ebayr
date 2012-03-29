# -*- encoding : utf-8 -*-
require "ebayr/version"
require 'net/https'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/hash/conversions'
require 'active_support/buffered_logger'

module Ebayr
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

  def self.uri_prefix
    "https://api#{sandbox ? ".sandbox" : ""}.ebay.com/ws"
  end

  # Gets the URI used for calls
  def self.uri
    URI::parse("#{uri_prefix}/api.dll")
  end

  def self.authorization_uri(session_id, ru_params = {})
    ruparams = CGI::escape(ru_params.map { |k, v| "#{k}=#{v}" }.join("&"))
    URI::parse("#{uri_prefix}/eBayISAPI.dll?SignIn&RuName=%s&SessId=#{session_id}&ruparams=#{ruparams}")
  end

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

  # Shorthand for call(call, arguments.merge(:auth_token => this.ebay_token))
  # Allows objects which mix in this module to use their own token.
  def ebay_call(call, arguments = {})
    raise "#{self} has no eBay token" unless ebay_token
    Ebay.call(call, arguments.merge(:auth_token => ebay_token))
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
