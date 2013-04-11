module SimpleDeploy
  class StackLister

    def initialize(args = {})
      @config = SimpleDeploy.config
    end

    def all
      entry_lister.all
    end

    private

    def entry_lister
      @entry_lister ||= EntryLister.new
    end
  end
end
