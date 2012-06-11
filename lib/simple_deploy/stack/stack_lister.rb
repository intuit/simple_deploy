module SimpleDeploy
  class StackLister

    def initialize(environment)
      @sl = Stackster::StackLister.new environment
    end
    
    def all
      @sl.all
    end

  end
end
