# -*- encoding : utf-8 -*-
require 'logger'
require 'net/https'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/hash/conversions'

# A library to assist in using the eBay Trading API.
module Ebayr
  autoload :Record,   File.expand_path('../ebayr/record', __FILE__)
  autoload :Request,  File.expand_path('../ebayr/request',  __FILE__)
  autoload :Response, File.expand_path('../ebayr/response', __FILE__)
  autoload :User,     File.expand_path('../ebayr/user',     __FILE__)

  # To make a call, you need to have a registered user and app. Then you must
  # fill in the <code>dev_id</code>, <code>app_id</code>, <code>cert_id</code>
  # and <code>ru_name</code>. You will also need an <code>auth_token</code>,
  # though you may use any user's token here.
  # See http://developer.ebay.com/DevZone/XML/docs/HowTo/index.html for more
  # details.
  mattr_accessor :dev_id
  mattr_accessor :app_id
  mattr_accessor :cert_id
  mattr_accessor :ru_name
  mattr_accessor :auth_token

  # Determines whether to use the eBay sandbox or the real site.
  mattr_accessor :sandbox
  self.sandbox = true

  # Set to true to generate fancier objects for responses (will decrease
  # performance).
  mattr_accessor :normalize_responses

  def self.normalize_responses?
    !!normalize_responses
  end

  def sandbox?
    !!sandbox
  end

  # This URL is used to redirect the user back after a successful registration.
  # For more details, see here:
  # http://developer.ebay.com/DevZone/XML/docs/WebHelp/wwhelp/wwhimpl/js/html/wwhelp.htm?context=eBay_XML_API&topic=GettingATokenViaFetchToken
  mattr_accessor :authorization_callback_url
  self.authorization_callback_url = 'https://example.com/'

  # This URL is used if the authorization process fails - usually because the user
  # didn't click 'I agree'. If you leave it nil, the
  # <code>authorization_callback_url</code> will be used (but the parameters will be
  # different).
  mattr_accessor :authorization_failure_url
  self.authorization_failure_url = nil

  # Callbacks which are invoked at various points throughout a request.
  mattr_accessor :callbacks
  self.callbacks = {
    :before_request   => [],
    :after_request    => [],
    :before_response  => [],
    :after_response   => [],
    :on_error         => []
  }

  # The eBay Site to use for calls. The full list of available sites can be
  # retrieved with <code>GeteBayDetails(:DetailName => "SiteDetails")</code>
  mattr_accessor :site_id
  self.site_id = 0

  # eBay Trading API version to use. For more details, see
  # http://developer.ebay.com/devzone/xml/docs/HowTo/eBayWS/eBaySchemaVersioning.html
  mattr_accessor :compatability_level
  self.compatability_level = 837

  mattr_accessor :logger
  self.logger = Logger.new(STDOUT)
  self.logger.level = Logger::INFO

  mattr_accessor :debug
  self.debug = false

  # Gets either ebay.com/ws or sandbox.ebay.com/ws, as appropriate, with
  # "service" prepended. E.g.
  #
  #     Ebayr.uri_prefix("blah")  # => https://blah.ebay.com/ws
  #     Ebayr.uri_prefix          # => https://api.ebay.com/ws
  def uri_prefix(service = "api")
    "https://#{service}#{sandbox ? ".sandbox" : ""}.ebay.com/ws"
  end

  # Gets the URI used for API calls (as a URI object)
  def uri(*args)
    URI::parse("#{uri_prefix(*args)}/api.dll")
  end

  # Gets the URI for eBay authorization/login. The session_id should be obtained
  # via an API call to GetSessionID (be sure to use the right ru_name), and the
  # ru_params can contain anything (they will be passed back to your app in the
  # redirect from eBay upon successful login and authorization).
  def authorization_uri(session_id, ru_params = {})
    ruparams = CGI::escape(ru_params.map { |k, v| "#{k}=#{v}" }.join("&"))
    URI::parse("#{uri_prefix("signin")}/eBayISAPI.dll?SignIn&RuName=#{ru_name}&SessId=#{session_id}&ruparams=#{ruparams}")
  end

  # Perform an eBay call (symbol or string). You can pass in these arguments:
  #
  # auth_token:: to use a user's token instead of the general token
  # site_id:: to use a specific eBay site (default is 0, which is US ebay.com)
  # compatability_level:: declare another eBay Trading API compatability_level
  #
  # All other arguments are passed into the API call, and may be nested.
  #
  #     response = call(:GeteBayOfficialTime)
  #     response = call(:get_ebay_official_time)
  #
  # See Ebayr::Request for details.
  #
  # The response is a special Hash of the response, deserialized from the XML
  #
  #     response.timestamp     # => 2010-10-10 10:00:00 UTC
  #     response[:timestamp]   # => 2010-10-10 10:00:00 UTC
  #     response['Timestamp']  # => "2012-10-10T10:00:00.000Z"
  #     response[:Timestamp]   # => "2012-10-10T10:00:00.000Z"
  #     response.ack           # "Success"
  #     response.success?      # true
  #
  #  See Ebayr::Response for details.
  #
  #  To see a list of available calls, check out
  #  http://developer.ebay.com/DevZone/XML/docs/Reference/ebay/index.html
  def call(command, arguments = {})
    Request.new(command, arguments).send
  end


  def self.included(mod)
    mod.extend(self)
  end

  extend self
end

# Override defaults with values from a config file, if there is one.
%W(/etc/ebayr.conf /usr/local/etc/ebayr.conf ~/.ebayr.conf ./.ebayr.conf).each do |path|
  load path if File.exists?(path = File.expand_path(path))
end

