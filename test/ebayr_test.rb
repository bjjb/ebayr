# -*- encoding : utf-8 -*-
require 'test_helper'

class EbayrTest < Test::Unit::TestCase
  def setup
    Ebayr.sandbox = true
  end

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
  def test_basic_usage
    xml = "<GeteBayOfficialTimeResponse><Ack>Succes</Ack><Timestamp>blah</Timestamp></GeteBayOfficialTimeResponse>"
    FakeWeb.register_uri(:post, Ebayr.uri, :body => xml)
    assert_nothing_raised "Failed the most basic test" do
      response = Ebayr.call(:GeteBayOfficialTime)
      assert_kind_of Ebayr::Response, response
      assert_equal 'blah', response.timestamp
    end
  end

  def test_sandbox_reports_accurately
    Ebayr.sandbox = false
    assert !Ebayr.sandbox?, "Ebayr::sandbox can't be set to false"
    Ebayr.sandbox = true
    assert Ebayr.sandbox?, "Ebayr::sandbox can't be set to true"
  end

  def test_ebayr_sandbox_uris
    assert Ebayr.sandbox, "Tests should run in the sandbox"
    assert_equal "https://api.sandbox.ebay.com/ws", Ebayr.uri_prefix, "Basic URI prefix is wrong"
    assert_equal "https://blah.sandbox.ebay.com/ws", Ebayr.uri_prefix("blah"), "Special URI prefix is wrong"
    assert_equal "https://api.sandbox.ebay.com/ws/api.dll", Ebayr.uri.to_s, "Basic URI is wrong"
  end

  def test_ebayr_uris
    Ebayr.sandbox = false
    assert_equal "https://api.ebay.com/ws", Ebayr.uri_prefix, "Basic URI prefix is wrong"
    assert_equal "https://blah.ebay.com/ws", Ebayr.uri_prefix("blah"), "Special URI prefix is wrong"
    assert_equal "https://api.ebay.com/ws/api.dll", Ebayr.uri.to_s, "Basic URI is wrong"
    Ebayr.sandbox = true
  end

  def test_extension_by_another_module
    mod = Module.new { extend Ebayr }
    check_common_methods(mod)
  end

  def test_inclusion_in_another_module
    mod = Module.new { extend Ebayr }
    check_common_methods(mod)
  end

  def test_common_methods
    check_common_methods
  end

  def test_defaults
    assert Ebayr.sandbox
    assert_equal "https://api.sandbox.ebay.com/ws/api.dll", Ebayr.uri.to_s
    assert_kind_of Logger, Ebayr.logger
  end
end
