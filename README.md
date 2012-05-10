# Routing

Provides a generic interface for routing services that can by used to calculate directions between geolocations.

It aims to make parsing and use-case specific data handling easy trough an extendable middleware stack (think of rack middleware for your routing service).

## Usage

```ruby
start = Routing::GeoPoint.new(:lat => 49, :lng => 9)
destination = Routing::GeoPoint.new(:lat => 48, :lng => 8.9)

route = Routing.new.calculate(start, destination)
```

### Middleware

```ruby
routing = Routing.new do |r|
  r.use MyMiddleware.new
  r.use MyRoutingCache.new
end

route = routing.calculate(start, destination)
```

### Custom Adapters

```ruby
routing = Routing.new(MyAdapter.new)
route = routing.calculate(start, destination)
```

## Installation

Add this line to your application's Gemfile:

    gem 'routing'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install routing

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
