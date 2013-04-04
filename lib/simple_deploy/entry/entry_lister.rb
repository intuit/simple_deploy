module SimpleDeploy
  class EntryLister

    def initialize(args)
      @domain = 'stacks'
      @config = args[:config]
    end

    def all
      if sdb_connect.domain_exists? @domain
        e = sdb_connect.select "select * from #{@domain}"
        entries = e.keys.map do |name|
          remove_region_from_entry(name)
        end
      end
      entries ? entries : []
    end

    private

    def sdb_connect
      @sdb_connect ||= AWS::SimpleDB.new :config => @config
    end

    def remove_region_from_entry(name)
      name.gsub(/-[a-z]{2}-[a-z]*-[0-9]{1,2}$/, '')
    end

  end
end
