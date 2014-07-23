require 'time'

class Routing
  module Adapter
    # Adapter for a NAVTEQ LBSP Routing Service v6 server.
    # It passes the {GeoPoint}s to the routing service and will return another
    # Array of {GeoPoint}s, representing the calculated route.
    class Navteq < RestAdapter
      def self.default_params
        {
          departure:          Time.now.utc.iso8601,
          mode0:              "fastest;car",
          language:           "de_DE",
          legattributes:      "all,-links",
          maneuverattributes: "position,travelTime,length,time"
        }
      end

      def initialize(attrs = {})
        attrs[:path] ||= '/routing/6.2/calculateroute.json'
        attrs[:parser] ||= ::Routing::Parser::NavteqSimple
        super(attrs)
      end
    end
  end
end
