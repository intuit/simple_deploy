require 'heirloom'
require 'simple_deploy/artifact/artifact_lister'

module SimpleDeploy
  class Artifact

    attr_accessor :metadata

    def initialize(args)
      @region = args[:region]
      @config = args[:config]
      @artifact = Heirloom::Artifact.new :config => @config.heirloom

      self.metadata = @artifact.show :name => args[:name],
                                     :id   => args[:id]
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
