require 'capistrano'
require 'capistrano/cli'

module SimpleDeploy
  class Stack
    class SSH

      def initialize(args)
        @config      = args[:config]
        @instances   = args[:instances]
        @environment = args[:environment]
        @ssh_user    = args[:ssh_user]
        @ssh_key     = args[:ssh_key]
        @stack       = args[:stack]
        @name        = args[:name]
        @attributes  = @stack.attributes
        @logger      = @config.logger
        @region      = @config.region @environment
      end

      def execute(args)
        create_execute_task args
        @task.execute
      end

      private

      def create_execute_task(args)
        if @instances.nil? || @instances.empty?
          raise "There are no running instances to execute this command."
        end

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
        ssh_gateway = @attributes['ssh_gateway']
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

    end
  end
end

