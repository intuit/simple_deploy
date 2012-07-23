require 'tinder'

module SimpleDeploy
  module Notifier
    class Campfire

      def initialize(args)
        @environment = args[:environment]
        @stack_name = args[:stack_name]
        @config = args[:config]
        @logger = @config.logger

        settings = @config.notifications['campfire']
        @token = settings['token']
        @subdomain = settings['subdomain']
        @room_ids = settings['room_ids']
        @campfire = Tinder::Campfire.new @subdomain, :token => @token
      end

      def send(message)
        @room_ids.each do |room_id|
          room = @campfire.find_room_by_id room_id
          room.speak message
        end
      end

    end
  end
end
