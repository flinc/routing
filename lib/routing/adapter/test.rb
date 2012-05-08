class Routing
  module Adapter

    # Simple test adapter, that just returns the same {GeoPoint}
    # that it recieved.
    class Test

      def calculate(geo_points)
        geo_points
      end
    end

  end
end