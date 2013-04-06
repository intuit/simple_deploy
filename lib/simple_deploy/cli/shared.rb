module SimpleDeploy
  module CLI

    module Shared

      def parse_attributes(args)
        attributes = args[:attributes]
        attrs      = []

        attributes.each do |attribs|
          key   = attribs.split('=').first.gsub(/\s+/, "")
          value = attribs.gsub(/^.+?=/, '')
          logger.info "Read #{key}=#{value}"
          attrs << { key => value }
        end
        attrs
      end

      def valid_options?(args)
        provided = args[:provided]
        required = args[:required]

        required.each do |opt|
          unless provided[opt]
            logger.error "Option '#{opt} (-#{opt[0]})' required but not specified."
            exit 1
          end
        end

        if required.include? :environment
          unless ResourceManager.instance.environments.keys.include? provided[:environment]
            logger.error "Environment '#{provided[:environment]}' does not exist."
            exit 1
          end
        end
      end

      def command_name
        self.class.name.split('::').last.downcase
      end

      def rescue_exceptions_and_exit
        yield
      rescue SimpleDeploy::Exceptions::Base
        exit 1
      end

    end

  end
end
