require_relative 'response'

module OPOWER
  module TimeSeries
    # Configuration defaults
    class Suggest
      include Response

      attr_accessor :host, :port, :client 

      # Create a connection to a specific OpenTSDB instance
      #
      # Params:
      #
      # host is the host IP (defaults to localhost)
      # port is the host's port (defaults to 4242)
      #
      # Returns:
      #
      # A client to play with
      def initialize (host = '127.0.0.1', port = 4242)
        @host = host
        @port = port

        @client = "http://#{host}:#{port}/"
      end

      # Returns suggestions for metric or tag names
      #
      # Params:
      # * query: the string to search for
      # * type: the type of item to search for
      # Type can be one of the following
      # * metrics: Provide suggestions for metric names
      # * tagk: Provide suggestions for tag names
      # * tagv: Provide suggestions for tag values
      #
      # Returns:
      # An array of suggestions

      def run_suggest (query, type = 'metrics')
        url = @client + "suggest?type=#{type}&q=#{query}"
        get_response url,''
      end

      def get_suggest (query, type = 'metrics')
        @client + "suggest?type=#{type}&q=#{query}"
      end
    end

  end
end
