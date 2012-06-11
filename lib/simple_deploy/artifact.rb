require 'heirloom'

module SimpleDeploy
  class Artifact
    def initialize(args)
      @info = Heirloom::Heirloom.info(args)[args[:sha]]
    end

    def s3_url(region)
      @info["#{region}-s3-url"]
    end

    def http_url(region)
      @info["#{region}-http-url"]
    end

    def https_url(region)
      @info["#{region}-https-url"]
    end
  end
end
