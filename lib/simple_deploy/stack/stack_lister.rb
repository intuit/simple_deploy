module SimpleDeploy
  class StackLister

    def initialize(args)
      @stack_lister = Stackster::StackLister.new :config => args[:config]
    end
    
    def all
      @stack_lister.all
    end

  end
end
