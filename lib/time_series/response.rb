require 'net/http'
require 'json'

module OPOWER
  module TimeSeries
    module Response

      # Returns:
      # Response in the specified format for the given http request
      def get_response (url, format)
        begin
          response = Net::HTTP.get_response(URI.parse(url))
          if format.to_sym == :json
            res = JSON.parse response.body
          else
            res = response.body
          end
        rescue Exception => e
          res = "ERROR: There is a problem while fetching data, please check whether OpenTSDB is running or not."
        end
        res
      end

      # Get URL
      def self.url
        @@url
      end

      def self.url=(url)
        @@url = url
      end

      def self.format
        @@format
      end

      def self.format=(format)
        @@format = format
      end

    end
  end
end

