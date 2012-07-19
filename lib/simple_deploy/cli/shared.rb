module SimpleDeploy
  module CLI
    module Shared

      def self.parse_attributes(args)
        attributes = args[:attributes]
        logger = args[:logger]

        attrs = []
        attributes.each do |attribs|
          key = attribs.split('=').first.gsub(/\s+/, "")
          value = attribs.gsub(/^.+?=/, '')
          logger.info "Read #{key}=#{value}"
          attrs << { key => value }
        end
        attrs
      end

      def self.valid_options?(args)
        provided = args[:provided]
        required = args[:required]

        required.each do |opt|
          unless provided[opt]
            puts "Option '#{opt} (-#{opt[0]})' required but not specified."
            exit 1
          end
        end

        if required.include? :environment
          unless Config.new.environments.keys.include? provided[:environment]
            puts "Environment '#{provided[:environment]}' does not exist."
            exit 1
          end
        end

      end

    end
  end
end
