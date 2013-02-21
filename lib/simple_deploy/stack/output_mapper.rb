module SimpleDeploy
  class Stack
    class OutputMapper

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

        pluralize_keys

        prune_unused_parameters

        @results.map { |x| { x.first => x.last } }
      end

      private

      def merge_stacks_outputs
        count = 0

        @stacks.each do |s|
          count += 1
          @logger.info "Reading outputs from stack '#{s}'."
          stack = Stack.new :environment => @environment,
                            :config      => @config,
                            :logger      => @logger,
                            :name        => s
          stack.wait_for_stable
          merge_outputs stack
          SimpleDeploy::Backoff.exp_periods(count < 5 ? count : 5) do |backoff|
            @logger.info "Backing off for #{backoff} seconds."
            sleep backoff
          end
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

      def pluralize_keys
        pluralized_keys = {}

        @results.each_pair do |key,value|
          pluralized_key = "#{key}s"
          if template_parameters.include? pluralized_key
            @logger.info "Passing '#{key}' as input parameter '#{pluralized_key}'."
            pluralized_keys[pluralized_key] = @results.fetch key
          end
        end

        @results.merge! pluralized_keys
      end

      def prune_unused_parameters
        @results.each_pair do |key,value|
          if template_parameters.include? key
            @logger.info "Passing output '#{key}' as input parameter with value '#{value}'."
          else
            @results.delete key
          end
        end
      end

      def template_parameters
        @parameters ||= Template.new(:file => @template).parameters
      end

    end
  end
end
