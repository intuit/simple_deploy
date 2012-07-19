module SimpleDeploy
  module CLI
    module Shared

      def self.parse_attributes(args)
        attributes = args[:attributes]
        logger = args[:logger]

        attrs = []
        attributes.each do |attribs|
          key = attribs.split('=').first.gsub(/\s+/, "")
          value = attribs.gsub(/^.+?=/, '')
          logger.info "Read #{key}=#{value}"
          attrs << { key => value }
        end
        attrs
      end

    end
  end
end
