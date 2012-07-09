module SimpleDeploy
  class StackAttributeFormater

    def initialize(args)
      @config = args[:config]
      @environment = args[:environment]
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

    def artifact_names
      @config.artifacts
    end
    
    def cloud_formation_url attribute
      name = attribute.keys.first
      id = attribute[name]
      a = @config.artifacts.select { |a| a['name'] == name }.first

      bucket_prefix = @config.artifact_bucket_prefix name
      cloud_formation_url = @config.artifact_cloud_formation_url name

      artifact = Artifact.new :name          => name,
                              :id            => id,
                              :region        => @region,
                              :config        => @config,
                              :bucket_prefix => bucket_prefix

      { cloud_formation_url => artifact.endpoints['s3'] }
    end

  end
end
