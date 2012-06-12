require 'heirloom'

module SimpleDeploy
  class Artifact

    attr_accessor :metadata

    def initialize(args)
      self.metadata = Heirloom::Heirloom.info(args)
    end

    def s3_url(region)
      key = "#{region}-s3-url"
      metadata[key] ? metadata[key].first : nil
    end

    def http_url(region)
      key = "#{region}-http-url"
      metadata[key] ? metadata[key].first : nil
    end

    def https_url(region)
      key = "#{region}-https-url"
      metadata[key] ? metadata[key].first : nil
    end
  end
end
