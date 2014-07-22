require 'time'

class Routing
  module Adapter
    # Adapter for a Nokia Here Routing Service v7 server.
    # It passes the {GeoPoint}s to the routing service and will return another
    # Array of {GeoPoint}s, representing the calculated route.
    class Here < RESTAdapter
      property :credentials, accepts: Hash

      def self.default_params
        {
          departure:          Time.now.utc.iso8601,
          mode:               "fastest;car",
          language:           "de_DE",
          legattributes:      "all,-links",
          maneuverattributes: "position,travelTime,length,time"
        }
      end

      def initialize(attrs = {})
        attrs[:host] ||= 'route.api.here.com'
        attrs[:path] ||= '/routing/7.2/calculateroute.json'
        attrs[:parser] ||= ::Routing::Parser::HereSimple
        super(attrs)
      end

      def calculate(geo_points)
        response = request(params.merge(convert_geo_points_to_params(geo_points)).merge(credentials))
        parse(response.body)
      end
    end
  end
end
