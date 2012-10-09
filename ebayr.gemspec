# -*- encoding : utf-8 -*-
$:.push(File.expand_path('../lib', __FILE__)) unless $:.include?(File.expand_path('../lib', __FILE__))
require 'ebayr/version'

Gem::Specification.new do |gem|
  gem.authors       = ["JJ Buckley"]
  gem.email         = ["jj@bjjb.org"]
  gem.description   = "A tidy library for using the eBay Trading API with Ruby"
  gem.summary       = <<-DESCRIPTION
eBayR is a gem that makes it (relatively) easy to use the eBay Trading API from
Ruby. Includes a self-contained XML parser, a flexible callback system, and a
command-line client which aids integration into other projects.
  DESCRIPTION
  gem.homepage      = "http://jjbuckley.github.com/ebayr"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^test/})
  gem.name          = "ebayr"
  gem.require_paths = ["lib"]
  gem.version       = Ebayr::VERSION
  gem.add_dependency 'activesupport'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'fakeweb'
end
