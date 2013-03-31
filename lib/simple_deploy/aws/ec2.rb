require 'fog'

module SimpleDeploy
  class AWS
    class EC2

      def initialize(args)
        c = args[:config]
        @connect = Fog::Compute::AWS.new :aws_access_key_id => c.access_key,
                                         :aws_secret_access_key => c.secret_key,
                                         :region => c.region
      end

      def describe_instance(instance)
        @connect.describe_instances('instance-state-name' => 'running',
                                    'instance-id' => instance).body['reservationSet']
      end
    end
  end
end
