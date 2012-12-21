module SimpleDeploy
  module Exceptions

    class Base < RuntimeError
      attr_accessor :message

      def initialize(message="")
        @message = message
      end
    end

  end
end
