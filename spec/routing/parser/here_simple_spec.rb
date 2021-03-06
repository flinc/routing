require 'spec_helper'
require 'json'

describe Routing::Parser::HereSimple do
  context 'with a error response' do
    let(:error_response) { fixture('here/error_response.json') }

    it 'should throw an RoutingFailed error' do
      expect{ described_class.new(error_response) }.to raise_error(Routing::Parser::RoutingFailed)
    end
  end

  context 'with a successful routing response' do
    let(:response) { fixture('here/response.json') }
    let(:json_response) { JSON.parse(response) }
    let(:original_geo_points) do
      json_response['response']['route'].first['waypoint'].collect do |waypoint|
        double({
          lat: waypoint['originalPosition']['latitude'],
          lng: waypoint['originalPosition']['longitude']
        })
      end
    end

    describe '#to_geo_points' do
      subject { described_class.new(response).to_geo_points }

      it 'returns geopoints' do
        subject.each { |point| expect(point).to be_a(::Routing::GeoPoint) }
      end

      describe 'number of geo points' do
        let(:leg_size) { json_response["response"]["route"].first["leg"].size }
        let(:leg_touching_point_size) { leg_size - 1 }
        let(:maneuver_size) { json_response["response"]["route"].first["leg"].inject(0) { |sum, leg| sum + leg["maneuver"].size } }

        it 'has the length of all maneuvers minus the duplicate ones at the touching points' do
          expect(subject.size).to eq(maneuver_size - leg_touching_point_size)
        end
      end

      describe 'coordinates' do
        it 'sets the calculated latitude and longitude for each geo point' do
          subject.each do |geo_point|
            expect(geo_point.lat).to be
            expect(geo_point.lng).to be
          end
        end
      end

      describe 'original waypoints' do
        subject { described_class.new(response).to_geo_points.select(&:waypoint?) }

        it 'includes the same number of waypoints as passed in' do
          expect(subject.size).to eq(original_geo_points.size)
        end

        it 'sets original_lat and original_lng on the waypoints' do
          subject.each_with_index do |geo_point, index|
            expect(geo_point.original_lat).to eq(original_geo_points[index].lat)
            expect(geo_point.original_lng).to eq(original_geo_points[index].lng)
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
            expect { subject }.to raise_error(Routing::Parser::NoMatchingMappedPositionFound, 'Mapped waypoints did not match with geopoint')
          end
        end

        context 'when response does not contain enough waypoints to map them on the maneuvers' do
          let(:response) do
            corrupted_response = JSON.parse(fixture('here/response.json'))
            corrupted_response['response']['route'].first['waypoint'].pop
            JSON.dump(corrupted_response)
          end

          it 'raises an exception if no matching original position was found' do
            expect { subject }.to raise_error(Routing::Parser::NoMatchingMappedPositionFound, 'No more waypoints available')
          end
        end
      end
    end
  end

  # The fixture used here shows a response from the Here routing service that contains different
  # values in the following fields:
  # route[] > waypoint[] > mappedPosition > latitude/longitude
  # route[] > leg[] > maneuver > position > latitude/longitude
  #
  # This two fields are supposed to contain the same values I think. Yet, they sometimes differ,
  # which caused the parser to fail. This spec assures the parser still works.
  context 'with a successful, but very large routing response that is not mappable by coordinates' do
    let(:response) { fixture('here/response_with_non_simple_mapping_2.json') }
    let(:json_response) { JSON.parse(response) }

    describe '#to_geo_points' do
      subject { described_class.new(response).to_geo_points }

      it 'returns geopoints' do
        subject.each { |point| expect(point).to be_a(::Routing::GeoPoint) }
      end
    end
  end

end
