# -*- encoding : utf-8 -*-
require 'test_helper'
require 'ebayr'
require 'webmock'

WebMock.enable!

describe Ebayr do
  before { Ebayr.sandbox = true }

  def check_common_methods(mod = Ebayr)
    assert_respond_to mod, :"dev_id"
    assert_respond_to mod, :"dev_id="
    assert_respond_to mod, :"cert_id"
    assert_respond_to mod, :"cert_id="
    assert_respond_to mod, :"ru_name"
    assert_respond_to mod, :"ru_name="
    assert_respond_to mod, :"auth_token"
    assert_respond_to mod, :"auth_token="
    assert_respond_to mod, :"compatability_level"
    assert_respond_to mod, :"compatability_level="
    assert_respond_to mod, :"site_id"
    assert_respond_to mod, :"site_id="
    assert_respond_to mod, :"sandbox"
    assert_respond_to mod, :"sandbox="
    assert_respond_to mod, :"sandbox?"
    assert_respond_to mod, :"authorization_callback_url"
    assert_respond_to mod, :"authorization_callback_url="
    assert_respond_to mod, :"authorization_failure_url"
    assert_respond_to mod, :"authorization_failure_url="
    assert_respond_to mod, :"callbacks"
    assert_respond_to mod, :"callbacks="
    assert_respond_to mod, :"logger"
    assert_respond_to mod, :"logger="
    assert_respond_to mod, :"uri"
  end

  # If this passes without an exception, then we're ok.
  describe "basic usage" do
    before { WebMock.stub_request(:post, Ebayr.uri).to_return(:body => xml) }
    let(:xml) { "<GeteBayOfficialTimeResponse><Ack>Succes</Ack><Timestamp>blah</Timestamp></GeteBayOfficialTimeResponse>" }

    it "runs without exceptions" do
      Ebayr.call(:GeteBayOfficialTime).timestamp.must_equal 'blah'
    end
  end

  it "correctly reports its sandbox status" do
    Ebayr.sandbox = false
    Ebayr.wont_be :sandbox?
    Ebayr.sandbox = true
    Ebayr.must_be :sandbox?
  end

  it "has the right sandbox URIs" do
    Ebayr.must_be :sandbox?
    Ebayr.uri_prefix.must_equal "https://api.sandbox.ebay.com/ws"
    Ebayr.uri_prefix("blah").must_equal "https://blah.sandbox.ebay.com/ws"
    Ebayr.uri.to_s.must_equal "https://api.sandbox.ebay.com/ws/api.dll"
  end

  it "has the right real-world URIs" do
    Ebayr.sandbox = false
    Ebayr.uri_prefix.must_equal "https://api.ebay.com/ws"
    Ebayr.uri_prefix("blah").must_equal "https://blah.ebay.com/ws"
    Ebayr.uri.to_s.must_equal "https://api.ebay.com/ws/api.dll"
    Ebayr.sandbox = true
  end

  it "works when as an extension" do
    mod = Module.new { extend Ebayr }
    check_common_methods(mod)
  end

  it "works as an inclusion" do
    mod = Module.new { extend Ebayr }
    check_common_methods(mod)
  end

  it "has the right methods" do
    check_common_methods
  end

  it "has decent defaults" do
    Ebayr.must_be :sandbox?
    Ebayr.uri.to_s.must_equal "https://api.sandbox.ebay.com/ws/api.dll"
    Ebayr.logger.must_be_kind_of Logger
  end
end
