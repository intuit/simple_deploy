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

      prune_relevant_parameters

      @results.map {|x| { x.first => x.last } }
    end

    private

    def merge_stacks_outputs
      @stacks.each do |s|
        stack = Stack.new :environment => @environment,
                          :config      => @config,
                          :logger      => @logger,
                          :name        => s
        merge_outputs stack
      end
    end

    def merge_outputs(stack)
      stack.outputs.each do |output|
        key   = output['OutputKey']
        value = output['OutputValue']

        if @results.has_key? key
          @results[key] += ",#{value}"
        else
          @results[key] = value
        end
      end
    end

    def prune_relevant_parameters
      @results.each_key do |key|
        @results.delete key unless template_parameters.include? key
      end
    end

    def template_parameters
      @parameters ||= Template.new(:file => @template).parameters
    end

  end
end
