require 'spec_helper'
require 'json'

describe Routing::Parser::NavteqSimple do

  context 'with a error response' do
    let(:error_response) { fixture('navteq/error_response.json') }

    it 'should throw an RoutingFailed error' do
      lambda{ described_class.new(error_response) }.should raise_error(Routing::Parser::RoutingFailed)
    end
  end

  context 'with a successful routing response' do
    let(:response) { fixture('navteq/response.json') }
    let(:json_response) { JSON.parse(response) }
    let(:original_geo_points) do
      json_response['Response']['Route'].first['Waypoint'].collect do |waypoint|
        mock({
          lat: waypoint['OriginalPosition']['Latitude'],
          lng: waypoint['OriginalPosition']['Longitude']
        })
      end
    end

    describe '#to_geo_points' do
      subject { described_class.new(response).to_geo_points }

      it 'returns geopoints' do
        subject.each { |point| point.should be_a(::Routing::GeoPoint) }
      end

      describe 'number of geo points' do
        let(:leg_size) { json_response["Response"]["Route"].first["Leg"].size }
        let(:leg_touching_point_size) { leg_size - 1 }
        let(:maneuver_size) { json_response["Response"]["Route"].first["Leg"].inject(0) { |sum, leg| sum + leg["Maneuver"].size } }

        it 'has the length of all maneuvers minus the duplicate ones at the touching points' do
          should have(maneuver_size - leg_touching_point_size).geo_points
        end
      end

      describe 'coordinates' do
        it 'sets the calculated latitude and longitude for each geo point' do
          subject.each do |geo_point|
            geo_point.lat.should be
            geo_point.lng.should be
          end
        end
      end

      describe 'original waypoints' do
        subject { described_class.new(response).to_geo_points.select(&:waypoint?) }

        it 'includes the same number of waypoints as passed in' do
          should have(original_geo_points.size).geo_points
        end

        it 'sets original_lat and original_lng on the waypoints' do
          subject.each_with_index do |geo_point, index|
            geo_point.original_lat.should eq(original_geo_points[index].lat)
            geo_point.original_lng.should eq(original_geo_points[index].lng)
          end
        end

        context 'when response does not contain the original waypoints' do
          let(:response) do
            corrupted_response = JSON.parse(fixture('navteq/response.json'))
            corrupted_response['Response']['Route'].first['Waypoint'].first['MappedPosition']['Latitude'] += 0.1
            corrupted_response['Response']['Route'].first['Waypoint'].first['MappedPosition']['Longitude'] += 0.1
            JSON.dump(corrupted_response)
          end

          it 'raises an exception if no matching original position was found' do
            expect { subject }.to raise_error(Routing::Parser::NoMatchingMappedPositionFound)
          end
        end
      end
    end
  end
end