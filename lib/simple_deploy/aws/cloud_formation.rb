require 'fog'

module SimpleDeploy
  class AWS
    class CloudFormation

      include Helpers

      def initialize
        @config  = SimpleDeploy.config
        @logger  = SimpleDeploy.logger
        @connect = Fog::AWS::CloudFormation.new connection_args
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

    end
  end
end
