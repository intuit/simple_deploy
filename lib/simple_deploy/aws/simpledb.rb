require 'fog'
require 'retries'

module SimpleDeploy
  class AWS
    class SimpleDB

      include Helpers

      def initialize
        @config  = SimpleDeploy.config
        @connect = Fog::AWS::SimpleDB.new connection_args
      end

      def retry_options
        {:max_retries => 3,
         :rescue => Excon::Errors::ServiceUnavailable,
         :base_sleep_seconds => 10,
         :max_sleep_seconds => 60}
      end

      def domains
        with_retries(retry_options) do
          @connect.list_domains.body['Domains']
        end
      end

      def domain_exists?(domain)
        domains.include? domain
      end

      def create_domain(domain)
        with_retries(retry_options) do
          @connect.create_domain(domain) unless domain_exists?(domain)
        end
      end

      def put_attributes(domain, key, attributes, options)
        with_retries(retry_options) do
          @connect.put_attributes domain, key, attributes, options
        end
      end

      def select(query)
        options = { 'ConsistentRead' => true }
        data = {}
        next_token = nil

        while true
          options.merge! 'NextToken' => next_token
          chunk = with_retries(retry_options) do
            @connect.select(query, options).body
          end
          data.merge! chunk['Items']
          next_token = chunk['NextToken']
          break unless next_token
        end

        data
      end

      def delete(domain, key)
        with_retries(retry_options) do
          @connect.delete_attributes domain, key
        end
      end

      def delete_items(domain, key, attributes)
        with_retries(retry_options) do
          @connect.delete_attributes domain, key, attributes
        end
      end

    end
  end
end
