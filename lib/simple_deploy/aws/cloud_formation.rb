require 'fog'

module SimpleDeploy
  class AWS
    class CloudFormation

      def initialize
        @config = SimpleDeploy.config
        @logger = SimpleDeploy.logger
        set_connection
      end

      def create(args)
        parameters = { 'Parameters' => args[:parameters] }
        data = { 'Capabilities' => ['CAPABILITY_IAM'],
                 'TemplateBody' => args[:template] }.merge parameters
        @connect.create_stack(args[:name], data)
        @logger.info "Cloud Formation stack creation completed."
      rescue Exception => e
        Error.new(:exception => e).process
      end

      def update(args)
        parameters = { 'Parameters' => args[:parameters] }
        data = { 'Capabilities' => ['CAPABILITY_IAM'],
                 'TemplateBody' => args[:template] }.merge parameters
        @connect.update_stack(args[:name], data)
        @logger.info "Cloud Formation stack update completed."
      rescue Exception => e
        Error.new(:exception => e).process
      end

      def destroy(name)
        @connect.delete_stack name
        @logger.info "Cloud Formation stack destroy completed."
      rescue Exception => e
        Error.new(:exception => e).process
      end

      def describe_stack(name)
        @connect.describe_stacks('StackName' => name).body['Stacks']
      rescue Exception => e
        Error.new(:exception => e).process
      end

      def stack_resources(name)
        @connect.describe_stack_resources('StackName' => name).body['StackResources']
      rescue Exception => e
        Error.new(:exception => e).process
      end

      def stack_events(name, limit)
        @connect.describe_stack_events(name).body['StackEvents'] [0..limit-1]
      rescue Exception => e
        Error.new(:exception => e).process
      end

      def stack_status(name)
        describe_stack(name).first['StackStatus']
      end

      def stack_outputs(name)
        describe_stack(name).last['Outputs']
      end

      def template(name)
        @connect.get_template(name).body['TemplateBody']
      rescue Exception => e
        Error.new(:exception => e).process
      end

      private

      def set_connection
        args = {
          aws_access_key_id: @config.access_key,
          aws_secret_access_key: @config.secret_key,
          region: @config.region
        }

        if @config.temporary_credentials?
          args.merge!({ aws_session_token: @config.session_token })
        end

        @connect = Fog::AWS::CloudFormation.new args
      end

    end
  end
end
