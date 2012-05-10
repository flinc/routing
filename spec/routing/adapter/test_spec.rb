require 'spec_helper'

describe Routing::Adapter::Test do

  context 'creating a new instance' do

    it 'can be instantiated without arguments' do
      expect { Routing::Adapter::Test.new }.to_not raise_error
    end

  end

  describe '#calculate' do

    let(:geo_points) { [stub(:lat => 1, :lng => 2), stub(:lat => 3, :lng => 4), stub(:lat => 5, :lng => 6)] }

    it 'returns an array of geopoints with values that are passed to the method' do
      subject.calculate(geo_points).each_with_index do |new_geo_point, index|
        new_geo_point.lat.should eql(geo_points[index].lat)
        new_geo_point.lng.should eql(geo_points[index].lng)
        new_geo_point.original_lng.should eql(geo_points[index].lng)
        new_geo_point.original_lng.should eql(geo_points[index].lng)
        new_geo_point.should be_waypoint
      end
    end

  end

end