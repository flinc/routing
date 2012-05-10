require "routing/version"

# The {Routing} class is the main entry point for the library.
class Routing

  autoload :Adapter,    "routing/adapter"
  autoload :GeoPoint,   "routing/geo_point"
  autoload :Middleware, "routing/middleware"
  autoload :Parser,     "routing/parser"

  # Creates a new instance of the routing class
  #
  # @param [Object] adapter Adapter for the routing service that should be used, defaults to {Routing::Adapter::Navteq}.
  def initialize(adapter = self.class.default_adapter)
    @adapter = adapter
    @middlewares = []

    yield(self) if block_given?
  end

  # Calculates a route for the passed {GeoPoint}s.
  # These will be passed through the middleware stack and will
  # finally be given to the configured adapter which calculates a route out of it.
  #
  # @param [Array<GeoPoint>] geo_points
  #   An array of geo points to calculate a route of.
  #
  # @return [Array<GeoPoint>]
  #   An array of geo points that represent the calculated route.
  def calculate(*geo_points)
    calculate_with_stack(geo_points.flatten, middlewares + [@adapter])
  end

  # @return [Array] The list of used middlewares.
  attr_reader :middlewares

  # Sets/replaces the used middleware stack.
  #
  # @param [Array] middlewares An array of middlewares to use
  #
  # @return [Array<Routing::Middleware>] The list of used middlewares.
  def middlewares=(middlewares)
    @middlewares = middlewares
  end

  # Adds an object to the middleware stack.
  #
  # @param [Routing::Middleware] middleware The middleware to append to the stack.
  #
  # @return [Array<Routing::Middleware>] Updated list of used middlewares.
  def use(middleware)
    @middlewares << middleware
  end

  class << self

    # Sets the default adapter/routing service.
    #
    # @return [Object] Default adapter.
    attr_writer :default_adapter

    # The default adapter/routing service that is used, if no one is specified.
    # Currently this is {Routing::Adapter::Navteq}.
    #
    # @return [Object] Current default adapter.
    def default_adapter
      @default_adapter ||= Routing::Adapter::Navteq.new
    end

  end

  private

  # Helper method that will iterate through the middleware stack.
  #
  # @param [Array<GeoPoint>] geo_points
  #   The array of geo points to be passed to the middleware.
  #
  # @param [Routing::Middleware] stack
  #   The remaining stack of middlewares to iterate through.
  def calculate_with_stack(geo_points, stack)
    stack.shift.calculate(geo_points) do |gp|
      calculate_with_stack(gp, stack)
    end
  end

end
