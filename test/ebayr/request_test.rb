# -*- encoding : utf-8 -*-
require 'test_helper'
require 'ebayr/request'

describe Ebayr::Request do

  describe "serializing input" do
    it "converts times" do
      result = Ebayr::Request.serialize_input(Time.utc(2010, 'oct', 31, 03, 15))
      result.must_equal "2010-10-31T03:15:00Z"
    end
  end

  describe "uri" do
    it "is the Ebayr one" do
      Ebayr::Request.new(:Blah).uri.must_equal(Ebayr.uri)
    end
  end

  describe "arrays" do
    it "converts multiple arguments in new function" do
      args = [{ :a => 1 }, { :a => [{:b => 1 }, { :b => 2 }] }]
      Ebayr::Request.new(:Blah, :input => args).input_xml.must_equal '<a>1</a><a><b>1</b><b>2</b></a>'
    end

    it "converts times" do
      args = [{ :Time => Time.utc(2010, 'oct', 31, 03, 15)}]
      result = Ebayr::Request.new(:Blah, args).input_xml
      result.must_equal "<Time>2010-10-31T03:15:00Z</Time>"
    end
  end

  describe "xml" do
    def request(*args)
      Ebayr::Request.xml(*args)
    end

    it "convets a hash" do
      request(:a => { :b => 123 }).must_equal '<a><b>123</b></a>'
    end

    it "converts an array" do
      request([{ :a => 1 }, { :a => 2 }]).must_equal "<a>1</a><a>2</a>"
    end

    it "converts a string" do
      request('boo').must_equal 'boo'
    end

    it "converts a number" do
      request(1234).must_equal '1234'
    end

    it "converts multiple arguments" do
      args = [{ :a => 1 }, { :a => [{:b => 1 }, { :b => 2 }] }]
      request(*args).must_equal '<a>1</a><a><b>1</b><b>2</b></a>'
    end

    describe "requester credentials" do
      it 'includes requester credentials when auth_token present' do
        my_token = "auth-token-123xyz"
        request = Ebayr::Request.new(:Blah, :auth_token => my_token)
        request.body.must_include "<RequesterCredentials>", "</RequesterCredentials>"
        request.body.must_include "<eBayAuthToken>#{my_token}</eBayAuthToken>"
      end

      it 'excludes requester credentials when auth_token not present' do
        request = Ebayr::Request.new(:Blah, :auth_token => nil)
        request.body.wont_include "<RequesterCredentials>", "</RequesterCredentials>"
        request.body.wont_include "<eBayAuthToken>", "</eBayAuthToken>"
      end
    end
  end

end
