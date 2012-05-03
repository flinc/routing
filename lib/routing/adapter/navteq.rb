require 'time'

class Routing
  module Adapter

    # Adapter for a NAVTEQ LBSP Routing Service v6 server.
    # It passes the {GeoPoint}s to the routing service and will return another
    # Array of {GeoPoint}s, representing the calculated route.
    class Navteq

      def calculate(geo_points)
        parse get(geo_points)
      end

      def get(geo_points)
        params = default_params.merge geo_points_to_params(geo_points)
        response = connection.get service_path, params
        response.body
      end

      def host
        "http://example.org"
      end

      def parse(response)
        ::Routing::Parser::NavteqSimple.new(response).to_geo_points
      end

      def default_params
        {
          departure:          Time.now.utc.iso8601,
          mode0:              "fastest;car",
          language:           "de_DE",
          legattributes:      "all,-links",
          maneuverattributes: "position,travelTime,length,time"
        }
      end

      protected

      # The path on the server to the routing service.      
      # This is determined by the server and should not be changed.
      #
      # @returns [String]
      #   Path to the routing service.
      def service_path
        "/routing/6.2/calculateroute.json"
      end

      def geo_points_to_params(geo_points)
        Hash[geo_points.each_with_index.map{|point, i| [ "waypoint#{i}", "geo!#{point.lat},#{point.lng}" ] }]
      end

      def connection
        @connection ||= Faraday.new(:url => host) do |builder|
          builder.request  :url_encoded
          builder.response :logger
          builder.adapter  :net_http
        end
      end

    end

  end
end