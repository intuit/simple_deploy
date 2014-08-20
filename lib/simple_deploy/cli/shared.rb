module SimpleDeploy
  module CLI

    module Shared

      def parse_attributes(args)
        attributes = args[:attributes]
        attrs      = []

        attributes.each do |attribs|
          key   = attribs.split('=').first.gsub(/\s+/, "")
          value = attribs.gsub(/^.+?=/, '')
          SimpleDeploy.logger.info "Read #{key}=#{value}"
          attrs << { key => value }
        end
        attrs
      end

      def valid_options?(args)
        provided = args[:provided]
        required = args[:required]

        if provided[:environment] && provided[:read_from_env]
          SimpleDeploy.logger.error "You cannot specify both --environment and --read-from-env"
          exit 1
        end

        if required.include?(:environment) && required.include?(:read_from_env)
          if !provided.include?(:environment) && !provided.include?(:read_from_env)
            msg = "Either '--environment' or '--read-from-env' is required but not specified"
            SimpleDeploy.logger.error msg
            exit 1
          end
        end

        required.reject { |i| [:environment, :read_from_env].include? i }.each do |opt|
          unless provided[opt]
            SimpleDeploy.logger.error "Option '#{opt} (-#{opt[0]})' required but not specified."
            exit 1
          end
        end

        validate_credential_env_vars if provided[:read_from_env]

        if provided[:environment]
          unless SimpleDeploy.environments.keys.include? provided[:environment]
            SimpleDeploy.logger.error "Environment '#{provided[:environment]}' does not exist."
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

      private

      def credential_env_vars_exist?
        !!ENV['AWS_ACCESS_KEY_ID'] &&
        !!ENV['AWS_SECRET_ACCESS_KEY'] &&
        !!ENV['AWS_REGION']
      end

      def validate_credential_env_vars
        unless credential_env_vars_exist?
          msg = "The following environment variables must be set when using --read-from-env: "
          msg << "AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION"
          SimpleDeploy.logger.error msg
          exit 1
        end
      end

    end

  end
end
