require 'fog'

module SimpleDeploy
  class AWS
    class SimpleDB

      def initialize
        c = SimpleDeploy.config
        @connect = Fog::AWS::SimpleDB.new :aws_access_key_id     => c.access_key,
                                          :aws_secret_access_key => c.secret_key,
                                          :region                => c.region
      end

      def domains
        @connect.list_domains.body['Domains']
      end

      def domain_exists?(domain)
        domains.include? domain
      end

      def create_domain(domain)
        @connect.create_domain(domain) unless domain_exists?(domain)
      end

      def put_attributes(domain, key, attributes, options)
        @connect.put_attributes domain, key, attributes, options
      end

      def select(query)
        options = { 'ConsistentRead' => true }
        data = {}
        next_token = nil
        
        while true
          options.merge! 'NextToken' => next_token
          chunk = @connect.select(query, options).body
          data.merge! chunk['Items']
          next_token = chunk['NextToken']
          break unless next_token
        end

        data
      end

      def delete(domain, key)
        @connect.delete_attributes domain, key
      end

    end
  end
end
