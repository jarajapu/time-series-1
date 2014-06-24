# -*- encoding: utf-8 -*-

module Opower
  module TimeSeries
    # Wraps the OpenTSDB result with response codes and result counts
    class Result
      attr_reader :status, :length, :results, :error_message

      def initialize(response, format = 'json', version = 2.0)
        @status = response.status
        @length = 0
        data = response.body

        if format == 'json'
          parse_results(data, version)
        elsif format == 'ascii'
          @size = data.split("\n").length
          @results = data
        end
      end

      def errors?
        @status.to_s !~ /^2/
      end

      private

      def parse_results(data, version)
        if version < 2.0
          @results = parse_json(data)
        else
          @results = JSON.parse(data) || []
          @length = @results.length

          if errors? && @length > 0
            @error_message = @results['error']['message'] unless @results['error'].nil?
          end
        end
      end

      # Parses the ASCII response from OpenTSDB 1.1 and creates an appropriate JSON representation.
      #
      # @param [String] data The ASCII string
      # @return [Object] JSON representation.
      def parse_json(data)
        data_arr = []
        return data_arr if data.nil?

        split = data.split("\n")
        @size = split.length

        split.each do |line|
          data_arr << parse_line(line.split("\s"))
        end

        data_arr
      end

      def parse_line(split_line)
        h = { 'metric' => split_line[0], 'ts' => split_line[1], 'value' => split_line[2] }
        tags = {}
        i = 3

        while i < split_line.length
          tag_data = split_line[i].split('=')
          tags[tag_data[0]] = tag_data[1]
          i += 1
        end

        h['tags'] = tags
        h
      end
    end
  end
end
