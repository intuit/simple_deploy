module SimpleDeploy
  class StackLister

    def initialize(args = {})
      @config = Config.new(:config => args[:config])
    end

    def all
      entry_lister.all
    end

    private

    def entry_lister
      @entry_lister ||= EntryLister.new :config => @config
    end
  end
end
