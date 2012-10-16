module SimpleDeploy
  class Backoff
    def self.exp_periods(num_periods = 3)
      (1..num_periods).each do |n|
        yield (1.0/2.0 * (2.0**n - 1.0)).ceil
      end
    end
  end
end
