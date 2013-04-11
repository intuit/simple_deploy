require 'rubygems'
require 'bundler/setup'
require 'fakefs/safe'
require 'timecop'

require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'simple_deploy'

['contexts'].each do |dir|
  Dir[File.expand_path(File.join(File.dirname(__FILE__),dir,'*.rb'))].each {|f| require f}
end

RSpec.configure do |config|
  #spec config
end
