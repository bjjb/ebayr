# -*- encoding : utf-8 -*-
require 'rubygems'
require 'spork'

require 'test/unit'
require 'turn'
require 'fakeweb'

require File.expand_path('../../lib/ebayr', __FILE__)
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do

end

Spork.each_run do

end
