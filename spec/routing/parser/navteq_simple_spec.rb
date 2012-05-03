require 'spec_helper'
require 'json'

describe Routing::Parser::NavteqSimple do

  let(:geo_point_array) do
    [
      Routing::GeoPoint.new(lat: 49.958, lng: 8.961),
      Routing::GeoPoint.new(lat: 49.8634, lng: 8.7523),
      Routing::GeoPoint.new(lat: 49.8752,  lng: 8.654)
    ]
  end

  let(:response) do
    # route = Routing::Adapter::Navteq.new.send :get, geo_point_array
    # File.open("./spec/fixtures/navteq/response.json", 'w') {|f| f.write(route.to_json) }
    File.open("./spec/fixtures/navteq/response.json").read
  end

  subject{ described_class.new(response) }

  let(:parsed_leg) { subject.parse_leg(subject.route["Leg"].first) }

  let(:maneuver_item) { subject.route["Leg"].first["Maneuver"].first }
  let(:parsed_maneuver_item) { subject.parse_maneuver(maneuver_item) }

  context 'creating a new instance' do

    its(:route) { should be_a(Hash) }

    it "should save the response" do
      subject.response.should == JSON.parse(response)
    end

  end

  describe '#to_geo_points' do

    it 'returns an array of geopoints' do
      subject.to_geo_points.should be_an(Array)
      subject.to_geo_points.first.should be_a(::Routing::GeoPoint)
    end

    describe 'length of the geopoint array' do

      let(:leg_size) { subject.route["Leg"].size }
      let(:leg_touching_point_size) { leg_size - 1 }
      let(:maneuver_size) { subject.route["Leg"].inject(0) {|sum, leg| sum + leg["Maneuver"].size } }

      it 'has the length of all maneuvers minus the duplicate ones at the touching points' do
        subject.to_geo_points.size.should == maneuver_size - leg_touching_point_size
      end

      it 'includes the same number of waypoints as passed in' do
        subject.to_geo_points.select(&:waypoint?).size == geo_point_array.size
      end

    end

  end

  describe '#parse_leg' do

    it 'collects all maneuvers as geo points' do
       parsed_leg.should be_an(Array)
       parsed_leg.first.should be_a(::Routing::GeoPoint)
    end

    it 'leaves out the first maneuver' do
      parsed_leg.size.should == subject.route["Leg"].first["Maneuver"].size - 1
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

    it 'sets distance and increases the overall distance' do
      old_distance = subject.overall_covered_distance
      subject.parse_maneuver(maneuver_item)
      subject.overall_covered_distance.should eql(old_distance + maneuver_item["Length"])
    end

    it 'sets time and increases the overall time' do
      old_time = subject.overall_relative_time
      subject.parse_maneuver(maneuver_item)
      subject.overall_relative_time.should eql(old_time + maneuver_item["TravelTime"])
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