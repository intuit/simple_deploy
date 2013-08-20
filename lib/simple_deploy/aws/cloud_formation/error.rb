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
          if @exception.respond_to?(:response)
            unless @exception.response.body.empty?
              message = XmlSimple.xml_in @exception.response.body
              message['Error'].first['Message'].each do |msg|
                case msg
                when 'No updates are to be performed.'
                  @logger.info msg
                when /Template requires parameter(.*)/
                  @logger.info msg
                when /^Stack:(.*) does not exist$/
                  @logger.error msg
                  raise Exceptions::UnknownStack.new msg
                else
                  @logger.error msg
                  raise Exceptions::CloudFormationError.new msg
                end
              end
            else
              @logger.error "CloudFormation returned blank xml EXCEPTION => #{@exception.response.body}" 
              raise Exceptions::CloudFormationError.new "Cloudformation returned blank xml"
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
