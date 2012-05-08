class Routing
  module Adapter

    # Simple test adapter, that returns an array of {GeoPoint}s
    # with values which are based on the ones it recieved.
    class Test

      def calculate(geo_points)
        geo_points.collect do |point|
          GeoPoint.new(
            :lat => point.lat,
            :lng => point.lng,
            :original_lat => point.lat,
            :original_lng => point.lng,
            :relative_time => 100,
            :distance => 100,
            :waypoint => true
          )
        end
      end
    end

  end
end