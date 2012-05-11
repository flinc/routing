require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

module RoutingFixtures
  def fixture(name)
    path = File.expand_path("../fixtures/#{name}", __FILE__)
    File.open(path).read
  end
end

RSpec.configure do |config|
  config.include RoutingFixtures
end

if File.exist?('.navteq_host')
  class Routing::Adapter::Navteq
    def host
      File.read('.navteq_host')
    end
  end
end