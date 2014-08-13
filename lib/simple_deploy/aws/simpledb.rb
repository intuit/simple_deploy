require 'fog'

module SimpleDeploy
  class AWS
    class SimpleDB

      def initialize
        @config = SimpleDeploy.config
        set_connection
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

      def delete_items(domain, key, attributes)
        @connect.delete_attributes domain, key, attributes
      end

      private

      def set_connection
        args = {
          aws_access_key_id: @config.access_key,
          aws_secret_access_key: @config.secret_key,
          region: @config.region
        }

        if @config.temporary_credentials?
          args.merge!({ aws_session_token: @config.session_token })
        end

        @connect = Fog::AWS::SimpleDB.new args
      end

    end
  end
end
