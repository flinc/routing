class Routing

  # A {GeoPoint} object is a very simple representation of a geospatial point
  # that is part of a route or can be used as base to create one.
  #
  # It holds the most basic textual and geospatial information that is necessary
  # to describe a section of a route.
  #
  # The complete roundtrip from a {Routing} object through the {Routing::Middleware} to a
  # {Routing::Adapter} and back uses arrays of {GeoPoint} objects as arguments.
  #
  # Depending on your very own use-case, you can either extend the {GeoPoint} class or
  # use another class that mimicks the behavior of {GeoPoint}.
  # In fact, this is just a container class which is no hard requirement in general.
  # If you decide to roll your own {Adapter}, {Parser} and maybe {Middleware},
  # you could replace the class completely
  class GeoPoint

    # Creates a new GeoPoint instance.
    #
    # @param [Hash] attributes
    #   Automatically sets values for the attributes that match the keys of the hash.
    def initialize(attributes = {})
      attributes.each do |attribute, value|
        send("#{attribute}=", value) if respond_to? attribute
      end
    end

    attr_accessor :lat

    attr_accessor :lng

    attr_accessor :original_lat

    attr_accessor :original_lng

    attr_accessor :relative_time

    attr_accessor :distance

    attr_accessor :waypoint

    attr_accessor :type

    def waypoint?
      waypoint && !waypoint.nil?
    end

  end
end