require 'heirloom'
require 'simple_deploy/artifact/artifact_lister'

module SimpleDeploy
  class Artifact

    attr_accessor :metadata

    def initialize(args)
      @region = args[:region]
      self.metadata = Heirloom::Heirloom.info(args)
    end

    def all_endpoints
      {
        's3' => s3_url,
        'http' => http_url,
        'https' => https_url
      }
    end

    def s3_url
      key = "#{@region}-s3-url"
      metadata[key] ? metadata[key].first : nil
    end

    def http_url
      key = "#{@region}-http-url"
      metadata[key] ? metadata[key].first : nil
    end

    def https_url
      key = "#{@region}-https-url"
      metadata[key] ? metadata[key].first : nil
    end
  end
end
