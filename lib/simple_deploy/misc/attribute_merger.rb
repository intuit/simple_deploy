module SimpleDeploy
  module Misc
    class AttributeMerger

      def merge(args)
        @attributes   = args[:attributes]
        @config       = SimpleDeploy.config
        @environment  = args[:environment]
        @input_stacks = args[:input_stacks]
        @template     = args[:template]

        combine_provided_and_mapped_attributes
      end

      private

      def combine_provided_and_mapped_attributes
        @attributes + mapped_attributes_not_provided
      end

      def mapped_attributes
        mapper.map_outputs_from_stacks :stacks   => @input_stacks,
                                       :template => @template
      end

      def mapped_attributes_not_provided
        mapped_attributes.reject do |a|
          provided_attribute_keys.include? a.keys.first
        end
      end

      def provided_attribute_keys
        @attributes.map {|a| a.keys.first}
      end

      def mapper
        @om ||= Stack::OutputMapper.new :environment => @environment
      end

    end
  end
end
