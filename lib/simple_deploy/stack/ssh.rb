require 'capistrano'
require 'capistrano/cli'

module SimpleDeploy
  class Stack
    class SSH

      def initialize(args)
        @config      = SimpleDeploy.config
        @logger      = SimpleDeploy.logger
        @stack       = args[:stack]
        @instances   = args[:instances]
        @environment = args[:environment]
        @ssh_user    = args[:ssh_user]
        @ssh_key     = args[:ssh_key]
        @name        = args[:name]
        @region      = @config.region
      end

      def execute(args)
        return false if @instances.nil? || @instances.empty?
        create_execute_task args

        status = false

        begin
          @task.execute
          status = true
          @logger.info "Command executed against instances successfully."
        rescue ::Capistrano::CommandError => error
          @logger.error "Error running execute statement: #{error}"
        rescue ::Capistrano::ConnectionError => error
          @logger.error "Error connecting to instances: #{error}"
        rescue ::Capistrano::Error => error
          @logger.error "Error: #{error}"
        end

        status
      end

      private

      def create_execute_task(args)

        @task = Capistrano::Configuration.new :output => @logger
        @task.logger.level = 3

        set_ssh_gateway
        set_ssh_user
        set_ssh_options
        set_instances
        set_execute_command args
      end

      def set_execute_command(args)
        command = args[:command]
        sudo    = args[:sudo]

        @logger.info "Setting command: '#{command}'."
        if sudo
          @task.variables[:default_run_options] = {:pty => true}
          @task.load :string => "task :execute do
          sudo '#{command}'
          end"
        else
          @task.load :string => "task :execute do
          run '#{command}'
          end"
        end
      end

      def set_instances
        @instances.each do |instance| 
          @logger.debug "Executing command on instance #{instance}."
          @task.server instance, :instances
        end
      end

      def set_ssh_options
        @logger.debug "Setting key to #{@ssh_key}."
        @task.variables[:ssh_options] = { :keys     => @ssh_key, 
                                          :paranoid => false }
      end

      def set_ssh_gateway
        ssh_gateway = attributes['ssh_gateway']
        if ssh_gateway && !ssh_gateway.empty?
          @task.set :gateway, ssh_gateway
          @logger.info "Proxying via gateway #{ssh_gateway}."
        else
          @logger.debug "Not using an ssh gateway."
        end
      end

      def set_ssh_user
        @logger.debug "Setting user to #{@ssh_user}."
        @task.set :user, @ssh_user
      end

      def attributes
        @stack.attributes
      end

    end
  end
end

