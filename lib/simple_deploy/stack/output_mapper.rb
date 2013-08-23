module SimpleDeploy
  class Stack
    class OutputMapper

      def initialize(args)
        @environment = args[:environment]
        @logger      = SimpleDeploy.logger
      end

      def map_outputs_from_stacks(args)
        @stacks   = args[:stacks]
        @template = args[:template]
        @clone = ( true && args[:clone] ) || false
        @results  = {}

        merge_stacks_outputs

        unless @clone
          pluralize_keys
          prune_unused_parameters
        end

        @results.each_pair do |key, value|
          @logger.info "Mapping output '#{key}' to input parameter with value '#{value}'."
        end

        @results.map { |x| { x.first => x.last } }
      end

      private

      def merge_stacks_outputs
        count = 0

        @stacks.each do |s|
          count += 1
          @logger.info "Reading outputs from stack '#{s}'."
          stack = Stack.new :environment => @environment,
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
        plural_params = @results.each_with_object({}) do |results, new|
          key            = results.first
          pluralized_key = "#{key}s"

          if template_parameters.include? pluralized_key
            new[pluralized_key] = results[1]
          end
        end

        @results.merge! plural_params
      end

      def prune_unused_parameters
        @results.select! { |key| template_parameters.include? key }
      end

      def template_parameters
        @parameters ||= Template.new(:file => @template).parameters
      end

    end
  end
end
