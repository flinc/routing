require 'spec_helper'
require 'json'

describe Routing::Parser::HereSimple do

  context 'with a error response' do
    let(:error_response) { fixture('here/error_response.json') }

    it 'should throw an RoutingFailed error' do
      lambda{ described_class.new(error_response) }.should raise_error(Routing::Parser::RoutingFailed)
    end
  end

  context 'with a successful routing response' do
    let(:response) { fixture('here/response.json') }
    let(:json_response) { JSON.parse(response) }
    let(:original_geo_points) do
      json_response['response']['route'].first['waypoint'].collect do |waypoint|
        mock({
          lat: waypoint['originalPosition']['latitude'],
          lng: waypoint['originalPosition']['longitude']
        })
      end
    end

    describe '#to_geo_points' do
      subject { described_class.new(response).to_geo_points }

      it 'returns geopoints' do
        subject.each { |point| point.should be_a(::Routing::GeoPoint) }
      end

      describe 'number of geo points' do
        let(:leg_size) { json_response["response"]["route"].first["leg"].size }
        let(:leg_touching_point_size) { leg_size - 1 }
        let(:maneuver_size) { json_response["response"]["route"].first["leg"].inject(0) { |sum, leg| sum + leg["maneuver"].size } }

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
            corrupted_response = JSON.parse(fixture('here/response.json'))
            corrupted_response['response']['route'].first['waypoint'].first['mappedPosition']['latitude'] += 0.1
            corrupted_response['response']['route'].first['waypoint'].first['mappedPosition']['longitude'] += 0.1
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
