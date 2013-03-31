module SimpleDeploy
  class Stack
    class StackFormatter

      def initialize(args)
        @name = args[:name]
        @config = args[:config]
      end

      def display
        { 
          'attributes'      => stack_reader.attributes,
          'status'          => stack_reader.status,
          'outputs'         => stack_reader.outputs,
          'events'          => stack_reader.events(3),
          'resources'       => stack_reader.resources,
        }
      end

      private

      def stack_reader
        @stack_reader ||= StackReader.new :name   => @name,
                                          :config => @config
      end
    end
  end
end
