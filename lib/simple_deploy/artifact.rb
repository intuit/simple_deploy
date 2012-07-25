module SimpleDeploy
  class Artifact

    def initialize(args)
      @bucket_prefix = args[:bucket_prefix]
      @config = args[:config]
      @id = args[:id]
      @name = args[:name]
      @region = args[:region]
      @domain = @config.artifact_domain @name

      @bucket = "#{@bucket_prefix}-#{@region}"
      @key = "#{@id}.tar.gz"
    end

    def endpoints
      { 's3' => s3_url, 'http' => http_url, 'https' => https_url }
    end

    private

    def s3_url
      "s3://#{@bucket}/#{@domain}/#{@key}"
    end

    def http_url
      "http://#{s3_endpoints[@region]}/#{@bucket}/#{@domain}/#{@key}"
    end

    def https_url
      "https://#{s3_endpoints[@region]}/#{@bucket}/#{@domain}/#{@key}"
    end

    def s3_endpoints
      {
        'us-east-1' => 's3.amazonaws.com',
        'us-west-1' => 's3-us-west-1.amazonaws.com',
        'us-west-2' => 's3-us-west-2.amazonaws.com'
      }
    end
  end
end
