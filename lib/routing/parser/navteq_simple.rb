class Routing
  module Parser

    # A very simple parser implementation for a NAVTEQ LBSP Routing Service v6.
    # It converts the json response of the routing service to an Array of {GeoPoint}s.
    class NavteqSimple

      # Creates a new instance of the parser.
      #
      # @param [String] response
      #  A json response string of a NAVTEQ routing server.
      def initialize(response)
        response = JSON.parse(response)
        check_for_error(response)

        @route = response["Response"]["Route"].first
        @overall_covered_distance  = 0
        @overall_relative_time = 0

        self
      end

      # Converts the server response in an Array of {GeoPoint}s
      #
      # @return [Array<GeoPoint>]
      #   List of {GeoPoint}s that represent the calculated route.
      def to_geo_points
        legs = @route["Leg"]
        geo_points = legs.map { |leg| parse_leg(leg) }.flatten

        # At last we add the destination point
        geo_points << parse_maneuver(legs.last["Maneuver"].last, waypoint: true)
        geo_points
      end

      # private

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
        maneuvers = leg["Maneuver"][0...-1]
        maneuvers.map do |maneuver|
          parse_maneuver(maneuver, :waypoint => (maneuver == maneuvers.first))
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
          lat: maneuver["Position"]["Latitude"],
          lng: maneuver["Position"]["Longitude"],
          relative_time: @overall_relative_time,
          distance: @overall_covered_distance
        })

        @overall_relative_time += maneuver["TravelTime"].to_i
        @overall_covered_distance += maneuver["Length"].to_i

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
        matching_waypoint = @route["Waypoint"].detect do |waypoint|
          waypoint["MappedPosition"]["Latitude"]  == geo_point.lat && 
          waypoint["MappedPosition"]["Longitude"] == geo_point.lng
        end or raise NoMatchingMappedPositionFound

        geo_point.original_lat = matching_waypoint["OriginalPosition"]["Latitude"]
        geo_point.original_lng = matching_waypoint["OriginalPosition"]["Longitude"]

        geo_point
      end

      def check_for_error(response)
        if error = response['Error']
          raise Routing::Parser::RoutingFailed.new("#{error['type']}(#{error['subtype']}) - #{error['Details']}")
        end
      end

    end
  end
end