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
        @response = JSON.parse(response)

        # only take the first route
        @route = self.response["Response"]["Route"].first
        @overall_covered_distance  = 0
        @overall_relative_time = 0

        self
      end

      # The server response, as a Ruby hash.
      #
      # @return [Hash]
      #  The response, converted from json into a Ruby hash.
      attr_accessor :response

      # Route from the response that will be parsed.
      # This will always be the first route returned.
      #
      # @return [Hash]
      #   The route, converted from json into a Ruby hash.
      attr_accessor :route

      # The overall distance of the parsed route in meters.
      #
      # @return [Fixnum]
      #   Overall distance in meters.
      attr_accessor :overall_covered_distance

      # The overall relative time of the parsed route in seconds.
      #
      # @return [Fixnum]
      #   Overall relative time in seconds.
      attr_accessor :overall_relative_time

      # Converts the server response in an Array of {GeoPoint}s
      #
      # @return [Array<GeoPoint>]
      #   List of {GeoPoint}s that represent the calculated route.
      def to_geo_points
        geo_points = []

        legs = route["Leg"]

        legs.each_with_index do |leg, index|
          geo_points += parse_leg(leg)
        end

        # At last we add the destination point
        geo_points << parse_maneuver(legs.last["Maneuver"].last, waypoint: true)

        # Search for the original input positions for every waypoint
        geo_points.select(&:waypoint?).each{|wp| search_original_position(wp) }

        geo_points
      end

      # Parses is single leg of the route including all its maneuvers.
      #
      # @param [Hash] leg
      #   The route leg to parse.
      #
      # @return [Array<GeoPoint>]
      #   List of {GeoPoint}s that represent the passed Leg.
      def parse_leg(leg)
        leg_geo_points = []

        maneuvers = leg["Maneuver"]

        # Skip the last maneuver as it is the same as the first one
        # of the next maneuver.
        # For the last leg we parse the last maneuver right at the end
        maneuvers[0...-1].each do |maneuver|
          leg_geo_points << parse_maneuver(maneuver, :waypoint => (maneuver == maneuvers.first))
        end

        leg_geo_points
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
        geopoint = ::Routing::GeoPoint.new attributes.merge({
          lat: maneuver["Position"]["Latitude"],
          lng: maneuver["Position"]["Longitude"],
          relative_time: overall_relative_time.to_i,
          distance: overall_covered_distance.to_i
        })

        @overall_relative_time += maneuver["TravelTime"]
        @overall_covered_distance += maneuver["Length"]

        geopoint
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
        waypoints = route["Waypoint"]
        matching_waypoint = route["Waypoint"].select do |waypoint|
          waypoint["MappedPosition"]["Latitude"] == geo_point.lat && waypoint["MappedPosition"]["Longitude"] == geo_point.lng
        end

        matching_waypoint = matching_waypoint.first or raise NoMatchingMappedPositionFound

        geo_point.original_lat = matching_waypoint["OriginalPosition"]["Latitude"]
        geo_point.original_lng = matching_waypoint["OriginalPosition"]["Longitude"]

        geo_point
      end

    end
  end
end