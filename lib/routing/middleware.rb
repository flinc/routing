class Routing
  # An abstract middleware class to illustrate how you can build your own.
  #
  # @abstract
  class Middleware

    # The only method your own middleware has to implement to work.
    #
    # @param [Array<GeoPoint>] geo_points
    #   The array of {GeoPoint}s that should be routed.
    #
    # @yield [Array<GeoPoint>]
    #   Passes the geo_points on to the next middleware in the stack.
    #   Please note, that you _always_ have to call yield in order to make
    #   the middleware stack proceed.
    #
    #   If you will return a value before yielding, you will cancel the rest of the middleware stack.
    #
    # @return [Array<GeoPoint>]
    #   The array of {GeoPoint}s after they have been routed.
    def calculate(geo_points)
      # manipulate geo points before routing here
      yield(geo_points) # hand control to the next middleware in the stack
      # manipulate geo points after routing here
    end

  end

end