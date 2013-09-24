# Ebayr

Ebayr is a small gem which makes it a little easier to use the eBay Trading API
with Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'ebayr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ebayr

## Usage

To use the eBay Trading API, you'll need a developer keyset. Sign up at
http://developer.ebay.com if you haven't already done so.

Next, you'll need to require Ebayr, and tell it to use your keys. You will also
need to generate an RUName, and get the key for that. (This is all standard
stuff - look at the [eBay developer docs][1] for details).

```ruby
require 'ebayr'

Ebayr.dev_id = "my-dev-id"

# This is only needed if you want to retrieve user tokens
Ebayr.authorization_callback_url = "https://my-site/callback-url"

Ebayr.auth_token = "myverylongebayauthtoken"

Ebayr.app_id = "my-ebay-app-id"

Ebayr.cert_id = "my-ebay-cert-id"

Ebayr.ru_name = "my-ebay-ru-name"

# Set this to true for testing in the eBay Sandbox (but remember to use the
# appropriate keys!). It's true by default.
Ebayr.sandbox = false
```

Now you're ready to make calls
```ruby
Ebayr.call(:GeteBayOfficialTime)
session = Ebayr.call(:GetSessionID, :RuName => Ebayr.ru_name)[:SessionID]
```

To use an authorized user's key, pass in an `auth_token` parameter
```ruby
Ebayr.call(:GetOrders, :auth_token => "another-ebay-auth-token")
```


### Configuration

Ebayr will look for the following Ruby files, and load them *once* in order (if
they exist) when the module is evaluated:

1. /etc/ebayr.conf
2. /usr/local/etc/ebayr.conf
3. ~/.ebayr.conf
4. ./.ebayr.conf

You can put configuration code in there (such as the variable setting shown
above). The files should be plain old Ruby.

In a Ruby on Rails project, just create a file called
config/initializers/ebayr.rb (or something), and put the configuration there. Of
course, you should probably not check in these files, if you're using a public
repository.

## Testing

[![Status](https://travis-ci.org/bjjb/ebayr.png?branch=master)](https://travis-ci.org/bjjb/ebayr)

When running test, you generally won't want to use up your API call-limit too
quickly, so it makes sense to stub out calls to the eBay API.

Ebayr has a small test helper library to help with this. It uses [Fakeweb][2]
for this, and just requires that you wrap your test code in a block, like this:

```ruby
require 'ebayr/test_helper'
class MyTest < Test::Unit::TestCase
  include Ebayr::TestHelper

  # A very contrived example...
  def test_fetching_user_id
    stub_ebay_call!(:GetUser, :UserID => "joebloggs") do
      assert_equal("joebloggs", Ebayr.call(:GetUser)['UserID'])
    end
  end
end
```

You need to remember to include Fakeweb in your Gemfile, or Ebayr will complain.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]: http://developer.ebay.com
[2]: http://fakeweb.rubyforge.org
