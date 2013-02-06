module SimpleDeploy
  module CLI
    module Misc
      class AttributeMerger

        def merge(args)
          @attributes  = args[:attributes]
          @config      = args[:config]
          @environment = args[:environment]
          @logger      = args[:logger]
          @stacks      = args[:stacks]
          @template    = args[:template]

          if @stacks.any?
            @logger.info "Reading outputs from stacks '#{@stacks.join(", ")}'." 
          end

          combine_provided_and_mapped_attributes 
        end

        private

        def combine_provided_and_mapped_attributes
          @attributes + mapped_attributes_not_provided
        end

        def mapped_attributes 
          mapper.map_outputs_from_stacks :stacks   => @stacks,
                                         :template => @template
        end

        def mapped_attributes_not_provided
          mapped_attributes.select do |a| 
            ! provided_attribute_keys.include? a.keys.first
          end
        end

        def provided_attribute_keys
          @attributes.map {|a| a.keys.first}
        end

        def mapper
          @om ||= StackOutputMapper.new :environment => @environment,
                                        :config      => @config,
                                        :logger      => @logger

        end

      end
    end
  end
end
