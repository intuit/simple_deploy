module SimpleDeploy
  class AWS
    module Helpers

      def connection_args
        {
          aws_access_key_id:     @config.access_key,
          aws_secret_access_key: @config.secret_key,
          region:                @config.region
        }.tap do |a|

          if @config.temporary_credentials?
            a.merge!({ aws_session_token: @config.session_token })
          end
        end
      end

    end
  end
end
