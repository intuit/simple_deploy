require 'slack-notifier'

module SimpleDeploy
  class Notifier
    class Slack

      def initialize(args = {})
        @logger = SimpleDeploy.logger
        @notifier = ::Slack::Notifier.new SimpleDeploy.config.notifications['slack']['webhook_url']
      end

      def send(message)
        @logger.info "Sending Slack notification."
        @notifier.ping message
        @logger.info "Slack notification complete."
      end

    end
  end
end
