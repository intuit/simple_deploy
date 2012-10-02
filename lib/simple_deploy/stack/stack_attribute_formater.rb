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
      attributes.each do |attrhash|
        key = attrhash.keys.first
        if artifact_names.include? key
          url_hash = cloud_formation_url attrhash, attributes
          updates << url_hash
          @logger.info "Adding artifact attribute: #{url_hash}"
        end
      end
      attributes + updates
    end

    private

    def artifact_names
      @config.artifacts
    end

    def cloud_formation_url(selected_attribute, updated_attributes)
      name = selected_attribute.keys.first
      id = selected_attribute[name]

      bucket_prefix, domain = find_bucket_prefix_and_domain selected_attribute, updated_attributes
      artifact = Artifact.new :name          => name,
                              :id            => id,
                              :region        => @region,
                              :config        => @config,
                              :domain        => domain,
                              :bucket_prefix => bucket_prefix

      url_parameter = @config.artifact_cloud_formation_url name
      { url_parameter => artifact.endpoints['s3'] }
    end

    def find_bucket_prefix_and_domain(selected_attribute, updated_attributes)
      name = selected_attribute.keys.first

      bucket_match = updated_attributes.find { |h| h.has_key? "#{name}_bucket_prefix" }
      if bucket_match
        bucket_prefix = bucket_match["#{name}_bucket_prefix"]
      else
        bucket_prefix = @main_attributes["#{name}_bucket_prefix"]
      end

      domain_match = updated_attributes.find { |h| h.has_key? "#{name}_domain" }
      if domain_match
        domain = domain_match["#{name}_domain"]
      else
        domain = @main_attributes["#{name}_domain"]
      end

      [bucket_prefix, domain]
    end
  end
end
