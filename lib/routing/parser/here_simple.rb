class Routing
  module Parser

    # A very simple parser implementation for a Nokia Here Routing Service v7.
    # It converts the json response of the routing service to an Array of {GeoPoint}s.
    class HereSimple

      # Creates a new instance of the parser.
      #
      # @param [String] response
      #  A json response string of a Nokia Here routing server.
      def initialize(response)
        response = JSON.parse(response)
        check_for_error(response)

        @route = response["response"]["route"].first
        @waypoints = @route["waypoint"].dup
        @overall_covered_distance  = 0
        @overall_relative_time = 0
      end

      # Converts the server response in an Array of {GeoPoint}s
      #
      # @return [Array<GeoPoint>]
      #   List of {GeoPoint}s that represent the calculated route.
      def to_geo_points
        legs = @route["leg"]
        geo_points = legs.map { |leg| parse_leg(leg) }.flatten

        # At last we add the destination point
        geo_points << parse_maneuver(legs.last["maneuver"].last, waypoint: true)
        geo_points
      end

      private

      # Parses is single leg of the route including all its maneuvers.
      #
      # @param [Hash] leg
      #   The route leg to parse.
      #
      # @return [Array<GeoPoint>]
      #   List of {GeoPoint}s that represent the passed Leg.
      def parse_leg(leg)
        # Skip the last maneuver as it is the same as the first one
        # of the next maneuver.
        # For the last leg we parse the last maneuver right at the end
        maneuvers = leg["maneuver"][0...-1]
        maneuvers.map do |maneuver|
          parse_maneuver(maneuver, waypoint: (maneuver == maneuvers.first))
        end
      end

      # Parses is single maneuver of a route leg.
      #
      # @param [Hash] maneuver
      #   The maneuver to parse.
      #
      # @param [Hash] attributes
      #   Additional attributes that should be set on the returned {GeoPoint}.
      #
      # @return [GeoPoint]
      #   A {GeoPoint} that represents the passed maneuver.
      def parse_maneuver(maneuver, attributes = {})
        geo_point = ::Routing::GeoPoint.new attributes.merge({
          lat: maneuver["position"]["latitude"],
          lng: maneuver["position"]["longitude"],
          relative_time: @overall_relative_time,
          distance: @overall_covered_distance
        })

        @overall_relative_time += maneuver["travelTime"].to_i
        @overall_covered_distance += maneuver["length"].to_i

        search_original_position(geo_point) if geo_point.waypoint?

        geo_point
      end

      # Matches a parsed {GeoPoint} of the route response
      # with the (unmapped) position of the
      # corresponding {GeoPoint} of the request.
      #
      # @param [GeoPoint] geo_point
      #   Point of the response to find the initial position for.
      #
      # @return [GeoPoint]
      #   The passed in {GeoPoint}, enriched with the information about the original position in the request.
      #
      # @raise [NoMatchingMappedPositionFound] If no matching original position is found.
      def search_original_position(geo_point)
        next_waypoint = @waypoints.shift

        if next_waypoint.nil?
          raise NoMatchingMappedPositionFound.new("No more waypoints available")
        end

        if truncate(next_waypoint["mappedPosition"]["latitude"], 4) != truncate(geo_point.lat, 4) ||
          truncate(next_waypoint["mappedPosition"]["longitude"], 4) != truncate(geo_point.lng, 4)
          raise NoMatchingMappedPositionFound.new("Mapped waypoints did not match with geopoint")
        end

        geo_point.original_lat = next_waypoint["originalPosition"]["latitude"]
        geo_point.original_lng = next_waypoint["originalPosition"]["longitude"]

        geo_point
      end

      def check_for_error(response)
        if error = response['type'] && response['type'][/error/i]
          raise Routing::Parser::RoutingFailed.new("#{response['type']}(#{response['subtype']}) - #{response['details']}")
        end
      end

      # Truncates (instead of rounding/ceiling/flooring) a float to the given precision.
      def truncate(float, precision)
        Integer(float * (10 ** precision)) / Float(10 ** precision)
      end

    end
  end
end
