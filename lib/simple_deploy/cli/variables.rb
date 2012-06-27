module SimpleDeploy
  module CLI
    def self.attributes
      attrs = []
      puts "\nRead the following attributes:\n\n"
      read_attributes.each do |attribs|
        key = attribs.split('=').first.gsub(/\s+/, "")
        value = attribs.gsub(/^.+?=/, '')
        puts "#{key} : #{value}"
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
