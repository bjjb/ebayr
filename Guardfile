# -*- encoding : utf-8 -*-
guard :test do
  watch(%r{^lib/(.+)\.rb$})       { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^test/(.+)_test\.rb$}) { |m| "test/#{m[1]}_test.rb" }
  watch('test/test_helper.rb')  { "test" }
end

# vi:ft=ruby
