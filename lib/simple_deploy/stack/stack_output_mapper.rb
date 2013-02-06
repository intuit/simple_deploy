module SimpleDeploy
  class StackOutputMapper

    def initialize(args)
      @config      = args[:config]
      @environment = args[:environment]
      @logger      = args[:logger]
    end

    def map_outputs_from_stacks(args)
      @stacks   = args[:stacks]
      @template = args[:template]
      @results  = {}

      merge_stacks_outputs

      prune_unused_parameters

      @results.map { |x| { x.first => x.last } }
    end

    private

    def merge_stacks_outputs
      @stacks.each do |s|
        @logger.debug "Reading outputs from stack '#{s}'."
        stack = Stack.new :environment => @environment,
                          :config      => @config,
                          :logger      => @logger,
                          :name        => s
        stack.wait_for_stable
        merge_outputs stack
      end
    end

    def merge_outputs(stack)
      stack.outputs.each do |output|
        key   = output['OutputKey']
        value = output['OutputValue']

        @logger.debug "Read output #{key}=#{value}."

        if @results.has_key? key
          @results[key] += ",#{value}"
        else
          @results[key] = value
        end
      end
    end

    def prune_unused_parameters
      @results.each_pair do |key,value|
        if template_includes_parameter? key
          @logger.info "Passing output '#{key}' as input parameter with value '#{value}'."
        else
          @results.delete key
        end
      end
    end

    def template_includes_parameter?(key)
      template_parameters.include? key
    end

    def template_parameters
      @parameters ||= Template.new(:file => @template).parameters
    end

  end
end
