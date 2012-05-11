require 'spec_helper'
require 'json'

describe Routing::Parser::NavteqSimple do

  let(:geo_point_array) do
    [
      mock(lat: 49.9580, lng: 8.9610),
      mock(lat: 49.8634, lng: 8.7523),
      mock(lat: 49.8752, lng: 8.6540)
    ]
  end

  let(:response) { fixture('navteq/response.json') }
  let(:json_response) { JSON.parse(response) }
  subject{ described_class.new(response) }

  let(:maneuver_item) { json_response["Response"]["Route"].first["Leg"].first["Maneuver"].first }
  let(:parsed_maneuver_item) { subject.parse_maneuver(maneuver_item) }

  context 'parsing an error from the server' do

    let(:error_response) { fixture('navteq/error_response.json') }

    it 'should throw an RoutingFailed error' do
      lambda{ described_class.new(error_response) }.should raise_error(Routing::Parser::RoutingFailed)
    end
  end

  describe '#to_geo_points' do

    it 'returns an array of geopoints' do
      subject.to_geo_points.should be_an(Array)
      subject.to_geo_points.first.should be_a(::Routing::GeoPoint)
    end

    describe 'length of the geopoint array' do

      let(:leg_size) { json_response["Response"]["Route"].first["Leg"].size }
      let(:leg_touching_point_size) { leg_size - 1 }
      let(:maneuver_size) { json_response["Response"]["Route"].first["Leg"].inject(0) { |sum, leg| sum + leg["Maneuver"].size } }

      it 'has the length of all maneuvers minus the duplicate ones at the touching points' do
        subject.to_geo_points.size.should == maneuver_size - leg_touching_point_size
      end

      it 'includes the same number of waypoints as passed in' do
        subject.to_geo_points.select(&:waypoint?).size == geo_point_array.size
      end

    end

  end

  describe '#parse_leg' do
    let(:parsed_leg) { subject.parse_leg(json_response["Response"]["Route"].first["Leg"].first) }

    it 'collects all maneuvers as geo points' do
       parsed_leg.should be_an(Array)
       parsed_leg.first.should be_a(::Routing::GeoPoint)
    end

    it 'leaves out the first maneuver' do
      parsed_leg.size.should == json_response["Response"]["Route"].first["Leg"].first["Maneuver"].size - 1
    end

    it 'marks only the first maneuver as waypoint' do
      parsed_leg.first.should be_waypoint
      parsed_leg.last.should_not be_waypoint
    end

  end

  describe '#parse_maneuver' do

    it 'returns a GeoPoint for a passed maneuver Hash' do
      parsed_maneuver_item.should be_a(Routing::GeoPoint)
    end

    it 'uses the lat value of the passed maneuver Hash' do
      subject.parse_maneuver(maneuver_item).lat.should be maneuver_item["Position"]["Latitude"]
    end

    it 'uses the lng value of the passed maneuver Hash' do
      subject.parse_maneuver(maneuver_item).lng.should be maneuver_item["Position"]["Longitude"]
    end

    it 'merges additionally passed attributes' do
      subject.parse_maneuver(maneuver_item, waypoint: true).waypoint.should be
    end

  end

  describe '#search_original_position' do

    it 'enriches a geo point with its original input position' do
      subject.search_original_position(parsed_maneuver_item).original_lat.should eql(geo_point_array.first.lat)
      subject.search_original_position(parsed_maneuver_item).original_lng.should eql(geo_point_array.first.lng)
    end

    it 'raises an exception if no matching original position was found' do
      lambda{ subject.search_original_position(Routing::GeoPoint.new(lat: 0, lng: 0)) }.should raise_error(Routing::Parser::NoMatchingMappedPositionFound)
    end

  end

end