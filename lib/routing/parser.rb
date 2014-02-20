class Routing
  # The {Routing::Parser} namespace holds classes that are used to parse the
  # response of a specific routing service.
  #
  # They are used by the matching adapters {Routing::Adapter} to create the array of {Routing::GeoPoint} objects
  # to pass into the middleware.
  module Parser

    autoload :NavteqSimple, "routing/parser/navteq_simple"
    autoload :HereSimple, "routing/parser/here_simple"

    # This error is thrown by the parsers if a calculated waypoint can't be matched
    # to one of the initial passed geo points that were routed.
    #
    # The reason why this is important is that most routing services have a "snap-to-route"
    # algorithm that will manipulate the coordinates of a passed geo point by moving it to
    # the next routeable position.
    # A parser should be able to determine which geo point of the response belongs to which geo point of the
    # request. Otherwise this error will be thrown.
    class NoMatchingMappedPositionFound < StandardError
    end

    class RoutingFailed < StandardError
    end

  end
end
