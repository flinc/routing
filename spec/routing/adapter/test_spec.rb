require 'spec_helper'

describe Routing::Adapter::Test do

  context 'creating a new instance' do

    it 'can be instantiated without arguments' do
      expect { Routing::Adapter::Test.new }.to_not raise_error
    end

  end

  describe '#calculate' do

    let(:geo_points) { [double(:lat => 1, :lng => 2), double(:lat => 3, :lng => 4), double(:lat => 5, :lng => 6)] }

    it 'returns an array of geopoints with values that are passed to the method' do
      subject.calculate(geo_points).each_with_index do |new_geo_point, index|
        expect(new_geo_point.lat).to eql(geo_points[index].lat)
        expect(new_geo_point.lng).to eql(geo_points[index].lng)
        expect(new_geo_point.original_lng).to eql(geo_points[index].lng)
        expect(new_geo_point.original_lng).to eql(geo_points[index].lng)
        expect(new_geo_point).to be_waypoint
      end
    end

  end

end