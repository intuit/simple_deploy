require 'xmlsimple'

module SimpleDeploy
  class AWS
    class CloudFormation
      class Error

        def initialize(args)
          @logger    = SimpleDeploy.logger
          @exception = args[:exception]
        end

        def process
          message = @exception.message
          unless message.empty?
            case message 
            when 'No updates are to be performed.'
              @logger.info message 
            when /^Stack:(.*) does not exist$/
              @logger.error message
              raise Exceptions::UnknownStack.new message
            else
              @logger.error message
              raise Exceptions::CloudFormationError.new message
            end
          else
            @logger.error "Unknown exception from cloudformation #{@exception.inspect}"
            raise Exceptions::CloudFormationError.new "Unknown exception from cloudformation"
          end
        end
      end
    end
  end
end
