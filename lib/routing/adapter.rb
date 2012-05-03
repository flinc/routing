class Routing

  # The {Routing::Adapter} namespace holds classes that are responsible to accept an
  # array of {Routing::GeoPoint}s and calculate a route based on these positions.
  #
  # Most commonly they will get the calculated route from a webservice and will create a compatible
  # return value by using a matching {Routing::Parser}.
  #
  # The end-point of the middleware stack is always the chosen adapter of a {Routing} instance which has to return the
  # calculated route in form of {Routing::GeoPoint} objects again.
  #
  # Creating your own adapter:
  # To connect your own routing service, you can easily implement your own adapter.
  # The only requirements are an instance method called *calculate* that will take an Array of {Routing::GeoPoint}s
  # as only parameters and will return an Array of {Routing::GeoPoint}s when the calculation is done.
  module Adapter

    autoload :Navteq, "routing/adapter/navteq"

  end
end