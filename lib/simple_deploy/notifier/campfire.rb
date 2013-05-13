require 'esbit'

module SimpleDeploy
  class Notifier
    class Campfire

      def initialize(args)
        @stack_name = args[:stack_name]
        @environment = args[:environment]
        @config = SimpleDeploy.config
        @logger = SimpleDeploy.logger

        attributes = stack.attributes
        @subdomain = attributes['campfire_subdomain']
        @room_ids = attributes['campfire_room_ids'] ||= ''
        @logger.debug "Campfire subdomain '#{@subdomain}'."
        @logger.debug "Campfire room ids '#{@room_ids}'."

        if @subdomain
          @token = @config.notifications['campfire']['token']
          @campfire = Esbit::Campfire.new @subdomain, @token
          @rooms = @campfire.rooms
        end
      end

      def send(message)
        @logger.info "Sending Campfire notifications."
        @room_ids.split(',').each do |room_id|
          room = @rooms.find { |r| r.id == room_id.to_i }
          if room
            @logger.debug "Sending notification to Campfire room #{room.name}."
            room.say message
          else
            @logger.warn "Could not find a room for id #{room_id}"
          end
        end
        @logger.info "Campfire notifications complete."
      end

      private

      def stack
        @stack ||= Stack.new :name        => @stack_name,
                             :environment => @environment
      end
    end

  end
end
