module SimpleDeploy
  class StackLister

    def self.list
      Stackster::StackLister.all
    end

  end
end
