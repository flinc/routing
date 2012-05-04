require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

RSpec.configure do |config|
end

if File.exist?('.navteq_host')
  class Routing::Adapter::Navteq
    def host
      File.read('.navteq_host')
    end
  end
end