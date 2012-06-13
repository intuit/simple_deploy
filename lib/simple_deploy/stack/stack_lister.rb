module SimpleDeploy
  class StackLister

    def initialize(args)
      @config = args[:config]
    end
    
    def all
      Stackster::Stack.list :config => @config
    end

  end
end
