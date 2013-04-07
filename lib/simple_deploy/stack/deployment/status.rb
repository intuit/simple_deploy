module SimpleDeploy
  class Stack
    class Deployment
      class Status

        def initialize(args)
          @config   = ResourceManager.instance.config
          @stack    = args[:stack]
          @ssh_user = args[:ssh_user]
          @name     = args[:name]
          @logger   = args[:logger]
        end

        def clear_for_deployment?
          !deployment_in_progress?
        end

        def clear_deployment_lock(force=false)
          if deployment_in_progress? && force
            @logger.info "Forcing. Clearing deployment status."
            unset_deployment_in_progress
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

        def unset_deployment_in_progress
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
