require 'time'
require 'faraday'
require 'smart_properties'

class Routing
  module Adapter
    class RestAdapter
      include SmartProperties

      property :scheme, converts: :to_str, accepts: ['http', 'https'], default: 'http', required: true
      property :host, converts: :to_str, required: true
      property :path, converts: :to_str, required: true
      property :parser, accepts: Class
      property :params, accepts: Hash

      def self.default_params
        {}
      end

      def calculate(geo_points)
        response = request(params.merge(convert_geo_points_to_params(geo_points)))
        parse(response.body)
      end

      def params
        super || self.class.default_params
      end

      private

      def base_url
        "%s://%s" % [scheme, host]
      end

      def request(params = nil)
        connection.get do |request|
          request.url(path)
          request.params = params if params
          yield request if block_given?
        end
      end

      def connection
        @connection ||= Faraday.new(url: base_url) do |builder|
          builder.request  :url_encoded
          builder.adapter  :net_http
        end
      end

      def parse(response)
        parser.new(response).to_geo_points
      end

      def convert_geo_points_to_params(geo_points)
        Hash[geo_points.each_with_index.map { |point, i| [ "waypoint#{i}", "geo!#{point.fetch(:lat)},#{point.fetch(:lng)}" ] }]
      end
    end
  end
end

