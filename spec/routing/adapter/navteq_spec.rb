require 'spec_helper'

describe Routing::Adapter::Navteq do
  let(:response) { double(:response).as_null_object }
  let(:request) { double(:request).as_null_object }
  let(:connection) { double(:connection).as_null_object }
  let(:parser_class) do
    Class.new.tap do |klass|
      klass.stub(new: parser)
    end
  end
  let(:parser) { double(:parser).as_null_object }
  let(:options) { { host: 'example.com', parser: parser_class } }

  let(:geo_points) do
    [
      Routing::GeoPoint.new(lat: 1, lng: 2),
      Routing::GeoPoint.new(lat: 3, lng: 4),
      Routing::GeoPoint.new(lat: 5, lng: 6)
    ]
  end

  subject(:adapter) { described_class.new(options) }

  before do
    allow(connection).to receive(:get).and_yield(request).and_return(response)
    allow(Faraday).to receive(:new).and_return(connection)
  end

  after { subject.calculate(geo_points) }

  context 'creating a new instance' do
    it 'allows setting the host' do
      expect(Faraday).to receive(:new).with(url: 'http://other.com')

      adapter = described_class.new(options.merge(host: 'other.com'))
      adapter.calculate(geo_points)
    end

    it 'allows setting the default params' do
      params = {hello: "world"}
      expect(request).to receive(:params=).with(hash_including(params))

      adapter = described_class.new(options.merge(params: params))
      adapter.calculate(geo_points)
    end

    it 'should allow setting the service path' do
      expect(request).to receive(:url).with('/some/path.json')

      adapter = described_class.new(options.merge(path: '/some/path.json'))
      adapter.calculate(geo_points)
    end

    it 'should use a default service path when none is given' do
      expect(request).to receive(:url).with('/routing/6.2/calculateroute.json')
      adapter.calculate(geo_points)
    end

    it 'should allow setting the parser' do
      expect(parser_class).to receive(:new)

      adapter = described_class.new(options.merge(parser: parser_class))
      adapter.calculate(geo_points)
    end

    it 'should use a default parser when none is given' do
      expect(Routing::Parser::NavteqSimple).to receive(:new).and_return(parser)

      adapter = described_class.new(host: 'example.com')
      adapter.calculate(geo_points)
    end

    it 'ignores unknown options' do
      expect { described_class.new(options.merge(hello: "world")) }.to_not raise_error
    end
  end

  describe '#calculate' do
    it 'passes the response body to the parser' do
      response.stub(body: '...')
      expect(parser_class).to receive(:new).with('...')
      adapter.calculate(geo_points)
    end

    it 'should return the parser\'s result' do
      result = [double, double, double]
      parser.stub(to_geo_points: result)
      expect(subject.calculate(geo_points)).to be(result)
    end

    it 'should convert the geo points into a compatible format' do
      expect(request).to receive(:params=).with hash_including({
        'waypoint0' => 'geo!1,2',
        'waypoint1' => 'geo!3,4',
        'waypoint2' => 'geo!5,6'
      })
    end
  end
end
