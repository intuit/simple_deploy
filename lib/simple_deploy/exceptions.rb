module SimpleDeploy
  module Exceptions

    class Base < RuntimeError
      attr_accessor :message

      def initialize(message="")
        @message = message
      end
    end
    
    class NoInstances < Base
    end

    class Exceptions::NoInstances < Base
    end

    class CloudFormationError < Base
    end

    class UnknownStack < Base
    end

    class IllegalStateException < Base
    end
  end
end
