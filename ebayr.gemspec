# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ebayr/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["JJ Buckley"]
  gem.email         = ["jj@bjjb.org"]
  gem.description   = %q{A tidy library for using the eBay Trading API with Ruby}
  gem.summary       = %q{eBayR is a gem that makes it (relatively) easy to use the eBay Trading API from Ruby. Includes a self-contained XML parser, a flexible callback system, and easy integration into Rails.}
  gem.homepage      = "http://jjbuckley.github.com/ebayr"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ebayr"
  gem.require_paths = ["lib"]
  gem.version       = Ebayr::VERSION
  gem.add_dependency 'activesupport'
  gem.add_development_dependency 'rake'
end
