require 'json'

module SimpleDeploy
  class StackCreator

    def initialize(args)
      @config = SimpleDeploy.config
      @logger = SimpleDeploy.logger
      @entry = args[:entry]
      @name = args[:name]
      @template = read_template_from_file args[:template_file]
    end

    def create
      @logger.info "Creating Cloud Formation stack #{@name}."
      cloud_formation.create :name => @name,
                             :parameters => read_parameters_from_entry,
                             :template => @template
    end

    private

    def cloud_formation
      @cf ||= AWS::CloudFormation.new
    end

    def read_template_from_file(template_file)
      file = File.open template_file
      file.read
    end

    def read_parameters_from_template
      t = JSON.parse @template
      t['Parameters'] ? t['Parameters'].keys : []
    end

    def read_parameters_from_entry
      h = {}
      attributes = @entry.attributes
      read_parameters_from_template.each do |p|
        h[p] = attributes[p] if attributes[p]
      end
      h
    end
  end
end
