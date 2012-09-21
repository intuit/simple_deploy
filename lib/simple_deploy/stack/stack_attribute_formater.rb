module SimpleDeploy
  class StackAttributeFormater

    def initialize(args)
      @config = args[:config]
      @environment = args[:environment]
      @main_attributes = args[:main_attributes]
      @region = @config.region @environment
      @logger = @config.logger
    end

    def updated_attributes(attributes)
      updates = []
      attributes.each do |attribute|
        key = attribute.keys.first
        if artifact_names.include? key
          updates << cloud_formation_url(attribute)
          @logger.info "Adding artifact attribute: #{cloud_formation_url(attribute)}"
        end
      end
      attributes + updates
    end

    private

    def artifact_names
      @config.artifacts
    end
    
    def cloud_formation_url attribute
      name = attribute.keys.first
      id = attribute[name]
      a = @config.artifacts.select { |a| a['name'] == name }.first

      bucket_prefix = @main_attributes["#{name}_bucket_prefix"]
      url_parameter = @config.artifact_cloud_formation_url name

      artifact = Artifact.new :name          => name,
                              :id            => id,
                              :region        => @region,
                              :config        => @config,
                              :bucket_prefix => bucket_prefix

      { url_parameter => artifact.endpoints['s3'] }
    end

  end
end
