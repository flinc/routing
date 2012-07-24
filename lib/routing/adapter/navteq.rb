require 'time'
require 'faraday'

class Routing
  module Adapter

    # Adapter for a NAVTEQ LBSP Routing Service v6 server.
    # It passes the {GeoPoint}s to the routing service and will return another
    # Array of {GeoPoint}s, representing the calculated route.
    class Navteq

      def initialize(options = {})
        @options = {
          :service_path => '/routing/6.2/calculateroute.json',
          :parser => ::Routing::Parser::NavteqSimple
        }.merge(options)
      end

      def calculate(geo_points)
        response = connection.get do |request|
          request.url(options[:service_path])
          request.params = default_params.merge(geo_points_to_params(geo_points))
        end
        parse(response.body)
      end

      private

      def parse(response)
        options[:parser].new(response).to_geo_points
      end

      def default_params
        options[:default_params] || {
          departure:          Time.now.utc.iso8601,
          mode0:              "fastest;car",
          language:           "de_DE",
          legattributes:      "all,-links",
          maneuverattributes: "position,travelTime,length,time"
        }
      end

      def geo_points_to_params(geo_points)
        Hash[geo_points.each_with_index.map { |point, i| [ "waypoint#{i}", "geo!#{point.lat},#{point.lng}" ] }]
      end

      def connection
        @connection ||= Faraday.new(:url => options[:host]) do |builder|
          builder.request  :url_encoded
          builder.adapter  :net_http
        end
      end

      def options
        @options || {}
      end

    end
  end
end