require 'rubygems'
require 'bundler/setup'
require 'fakefs/safe'
require 'timecop'

require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'simple_deploy'

RSpec.configure do |config|
  #spec config
end
