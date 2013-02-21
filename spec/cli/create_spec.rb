require 'spec_helper'
require 'simple_deploy/cli'

describe SimpleDeploy::CLI::Create do
  it "should create a stack with provided and merged attributes" do
    create = SimpleDeploy::CLI::Create.new
    options = { :attirubtes  => [ 'attr1=val1', 'attr2=val2' ],
                :stacks      => [ 'stack1' ],
                :environment => 'test',
                :name        => 'new_stack',
                :template    => '/tmp/test.json' }
    Trollop.stub :options => options
    create.create
  end
end
