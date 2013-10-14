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
          @logger.debug "Object type = #{@exception.class}"
          unless @exception.message.empty?
            case @exception.message 
            when 'No updates are to be performed.'
              @logger.info @exception.message 
            when /Template requires parameter(.*)/
              @logger.error @exception.message 
              raise Exceptions::CloudFormationError.new  @exception.message
            when /^Stack:(.*) does not exist$/
              @logger.error @exception.message
              raise Exceptions::UnknownStack.new @exception.message
            else
              @logger.error @exception.message
              raise Exceptions::CloudFormationError.new @exception.message
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
