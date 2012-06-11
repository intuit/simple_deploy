require 'heirloom'

module SimpleDeploy
  class Artifact

    def initialize(args)
      artifact = Heirloom::Heirloom.info(args)
      @info = artifact[args[:sha]]
    end

    def s3_url(region)
      @info["#{region}-s3-url"]
    end

    def http_url(region)
      @info["#{region}-http-url"].first
    end

    def https_url(region)
      @info["#{region}-https-url"].first
    end
  end
end
