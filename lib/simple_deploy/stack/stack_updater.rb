require 'json'

module SimpleDeploy
  class StackUpdater

    def initialize(args)
      @config = SimpleDeploy.config
      @logger = SimpleDeploy.logger
      @entry = args[:entry]
      @name = args[:name]
      @template_body = args[:template_body]
    end

    def update_stack_if_changes(attributes, template_body = nil)
      changes = false

      if parameter_updated?(attributes)
        @logger.debug "Updated parameters found."
        changes = true
      end

      if template_body && template_body != @template_body
        @logger.debug "Updated template found."
        @template_body = template_body
        changes = true
      end

      if changes
        update
        true
      else
        @logger.debug "Neither the Cloud Formation parameters or template " \
                      "body require updating."
        false
      end
    end

    private

    def update
      if status.wait_for_stable
        @logger.info "Updating Cloud Formation stack #{@name}."
        cloud_formation.update :name       => @name,
                               :parameters => read_parameters_from_entry_attributes,
                               :template   => @template_body
      else
        raise "#{@name} did not reach a stable state."
      end
    end

    def parameter_updated?(attributes)
      (template_parameters - updated_parameters(attributes)) != template_parameters
    end

    def template_parameters
      json = JSON.parse @template_body
      json['Parameters'].nil? ? [] : json['Parameters'].keys
    end

    def updated_parameters attributes
      (attributes.map { |s| s.keys }).flatten
    end

    def read_parameters_from_entry_attributes
      h = {}
      entry_attributes = @entry.attributes
      template_parameters.each do |p|
        h[p] = entry_attributes[p] if entry_attributes[p]
      end
      h
    end

    def cloud_formation
      @cloud_formation ||= AWS::CloudFormation.new
    end

    def status
      @status ||= Status.new :name => @name
    end
  end
end
