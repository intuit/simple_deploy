require 'spec_helper'

describe SimpleDeploy::Backoff do
  describe 'exp_periods' do
    it 'should yield each period' do
      expected_periods = [2, 4, 8]

      i = 0
      SimpleDeploy::Backoff.exp_periods do |p|
        expected_periods[i].should == p
        i += 1
      end
    end

    it 'should generate and yield a specified number of periods' do
      expected_periods = [2, 4]

      i = 0
      SimpleDeploy::Backoff.exp_periods(2) do |p|
        expected_periods[i].should == p
        i += 1
      end
    end
  end
end
