require 'xmlsimple'

module SimpleDeploy
  class AWS
    class CloudFormation
      class Error

        def initialize(args)
          @exception = args[:exception]
          @logger    = args[:logger]
        end

        def process
          message = XmlSimple.xml_in @exception.response.body
          message['Error'].first['Message'].each do |msg|
            case msg
            when 'No updates are to be performed.'
              @logger.info msg
            when /^Stack:(.*) does not exist$/
              @logger.error msg
              raise Exceptions::UnknownStack.new msg
            else
              @logger.error msg
              raise Exceptions::CloudFormationError.new msg
            end
          end
        end

      end
    end
  end
end
