
module SimpleDeploy
  class Entry
    attr_accessor :name

    def initialize(args)
      @domain = 'stacks'
      @config = SimpleDeploy.config
      @logger = SimpleDeploy.logger
      @custom_attributes = {}
      @name = region_specific_name args[:name]
      create_domain
    end

    def self.find(args)
      Entry.new :name => args[:name]
    end

    def attributes
      u = {}

      attrs = sdb_connect.select "select * from stacks where itemName() = '#{name}'"
      if attrs.has_key? name
        u.merge! Hash[attrs[name].map { |k,v| [k, v.first] }]
      end

      u.merge @custom_attributes
    end

    def set_attributes(a)
      a.each { |attribute| @custom_attributes.merge! attribute }
    end

    def save
      @custom_attributes.merge! 'Name' => name
      @custom_attributes.merge! 'CreatedAt' => Time.now.utc.to_s

      current_attributes = attributes
      current_attributes.each_pair do |key,value|
        @logger.debug "Setting attribute #{key}=#{value}"
      end

      sdb_connect.put_attributes('stacks', 
                                  name, 
                                  current_attributes, 
                                 :replace => current_attributes.keys )

      @logger.debug "Save to SimpleDB successful."
    end

    def delete_attributes
      sdb_connect.delete('stacks', name)
      @logger.info "Delete from SimpleDB successful."
    end

    private

    def region_specific_name(name)
      "#{name}-#{@config.region}"
    end

    def create_domain
      sdb_connect.create_domain @domain
    end

    def sdb_connect
      @sdb_connect ||= AWS::SimpleDB.new
    end
  end

end
