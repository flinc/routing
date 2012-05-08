class Routing
  module Adapter

    # Simple test adapter, that just returns a copy of the {GeoPoint}s array
    # that it recieved (just copies the lat, lng values).
    class Test

      def calculate(geo_points)
        geo_points.collect{|point| GeoPoint.new(:lat => point.lat, :lng => point.lng) }
      end
    end

  end
end