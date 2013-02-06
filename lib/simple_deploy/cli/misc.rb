module SimpleDeploy
  module CLI
    module Misc
      class AttributeMerger

        def merge(args)
          @config      = args[:config]
          @environment = args[:environment]
          @logger      = args[:logger]
          attributes   = args[:attributes]
          stacks       = args[:stacks]
          template     = args[:template]

          @logger.info "Reading outputs from stacks '#{stacks.join(", ")}'." if stacks.any?

          mapped_attributes = mapper.map_outputs_from_stacks :stacks   => stacks,
                                                             :template => template

          attributes + mapped_attributes
        end

        private

        def mapper
          @om ||= StackOutputMapper.new :environment => @environment,
                                        :config      => @config,
                                        :logger      => @logger

        end

      end
    end
  end
end
