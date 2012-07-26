module SimpleDeploy
  class Stack
    class Deployment
      class Status

        def initialize
          @stack = args[:stack]
          @ssh_user = args[:ssh_user]
          @name = args[:name]
        end

        def cleared_to_deploy?(force=false)
          return true unless deployment_in_progress?

          if force          
            @logger.info "Forcing. Clearing deployment status."
            clear_deployment_status
          else
            false
          end
        end

        def deployment_in_progress?
          @logger.debug "Checking deployment status for #{@name}."
          if attributes['deployment_in_progress'] == 'true'
            @logger.info "Deployment in progress for #{@name}."
            @logger.info "Started by #{attributes['deployment_user']}@#{attributes['deployment_datetime']}."
            true
          else
            @logger.debug "No other deployments in progress for #{@name}."
            false
          end
        end

        def set_deployment_in_progress
          @logger.debug "Setting deployment in progress by #{@ssh_user} for #{@name}."
          @stack.update :attributes => [ { 'deployment_in_progress' => 'true',
                                           'deployment_user'        => @ssh_user,
                                           'deployment_datetime'    => Time.now.to_s } ]
        end

        def clear_deployment_status
          @logger.debug "Clearing deployment in progress for #{@name}."
          @stack.update :attributes => [ { 'deployment_in_progress' => 'false' } ]
        end

        private

        def attributes
          @stack.attributes
        end

      end
    end
  end
end
