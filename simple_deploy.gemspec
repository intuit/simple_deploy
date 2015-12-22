# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simple_deploy/version"

Gem::Specification.new do |s|
  s.name        = "simple_deploy"
  s.version     = SimpleDeploy::VERSION
  s.authors     = ["Intuit Open Source"]
  s.email       = ["CTO-DevOpenSource@intuit.com"]
  s.homepage    = ""
  s.summary     = %q{Opinionated gem for AWS resource management.}
  s.description = %q{Opinionated gem for Managing AWS Cloud Formation stacks and deploying updates to Instances.}

  s.rubyforge_project = "simple_deploy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "fakefs", "~> 0.4.2"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 2.13.0"
  s.add_development_dependency "simplecov", "~> 0.7.1"
  s.add_development_dependency "timecop", "~> 0.6.1"

  s.add_runtime_dependency "capistrano", "= 2.13.5"
  s.add_runtime_dependency "esbit", "~> 0.0.4"
  s.add_runtime_dependency "trollop", "= 2.0"
  s.add_runtime_dependency "fog", "= 1.23.0"
  s.add_runtime_dependency "retries", "= 0.0.5"
  s.add_runtime_dependency "slack-notifier", "= 1.2.0"
end
