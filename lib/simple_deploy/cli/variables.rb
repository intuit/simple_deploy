module SimpleDeploy
  module CLI
    def self.attributes
      attrs = []
      read_attributes.each do |attribs|
        key = attribs.split('=').first.gsub(/\s+/, "")
        value = attribs.gsub(/^.+?=/, '')
        @logger.info "Read #{key}=#{value}"
        attrs << { key => value }
      end
      attrs
    end

    def self.read_attributes
      @opts[:attributes].nil? ? [] : @opts[:attributes]
    end                                         

    def self.environment_provided?
      @opts[:environment].nil? != true
    end

  end
end
