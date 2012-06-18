module SimpleDeploy
  module CLI
    def self.attributes
      attrs = []
      read_attributes.each do |attribs|
        a = attribs.split('=')
        attrs << { a.first.gsub(/\s+/, "") => a.last }
      end
      attrs
    end

    def self.read_attributes
      @opts[:attributes].nil? ? [] :  @opts[:attributes].split(',')
    end                                         

    def self.environment_provided?
      @opts[:environment].nil? != true
    end

  end
end
