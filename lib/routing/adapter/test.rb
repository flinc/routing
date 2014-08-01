class Routing
  module Adapter

    # Simple test adapter, that returns an array of {GeoPoint}s
    # with values which are based on the ones it recieved.
    class Test

      def calculate(geo_points)
        geo_points.collect do |point|
          lat = point[:lat]
          lng = point[:lng]

          raise ArgumentError, "latitude or longitude missing" unless lat && lng

          GeoPoint.new(
            :lat => lat,
            :lng => lng,
            :original_lat => lat,
            :original_lng => lng,
            :relative_time => 100,
            :distance => 100,
            :waypoint => true
          )
        end
      end
    end

  end
end
