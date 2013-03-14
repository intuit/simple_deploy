module SimpleDeploy
  class Backoff
    def self.exp_periods(num_periods = 3)
      (1..num_periods).each do |n|
        yield (2.0**n).ceil
      end
    end
  end
end
