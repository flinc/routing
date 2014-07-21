require 'spec_helper'

describe Routing::Adapter::Here do

  let(:response) { mock(:response).as_null_object }
  let(:request) { mock(:request).as_null_object }
  let(:connection) { mock(:connection).as_null_object }
  let(:parser_class) { mock(:parser_class, :new => parser) }
  let(:parser) { mock(:parser).as_null_object }

  let(:options) do
    { :parser => parser_class, :credentials => { :app_id => "123", :app_code => "456" } }
  end

  let(:geo_points) { [stub(:lat => 1, :lng => 2), stub(:lat => 3, :lng => 4), stub(:lat => 5, :lng => 6)] }

  subject(:adapter) { described_class.new(options) }

  before do
    connection.stub(:get).and_yield(request).and_return(response)
    Faraday.stub(:new).and_return(connection)
  end

  context 'creating a new instance' do
    it 'can be instantiated without arguments' do
      expect { described_class.new }.to_not raise_error
    end

    it 'allows setting the host' do
      Faraday.should_receive(:new).with(:url => 'http://other.com')

      adapter = described_class.new(options.merge!(:host => 'http://other.com'))
      adapter.calculate(geo_points)
    end

    it 'allows setting the default params' do
      params = { :hello => "world" }
      request.should_receive(:params=).with(hash_including(params))

      adapter = described_class.new(options.merge(:default_params => params))
      adapter.calculate(geo_points)
    end

    it 'sets the api credentials' do
      request.should_receive(:params=).with(hash_including({ :app_id => "123", :app_code => "456" }))
      adapter.calculate(geo_points)
    end

    it 'should allow setting the service path' do
      request.should_receive(:url).with('/some/path.json')

      adapter = described_class.new(options.merge(:service_path => '/some/path.json'))
      adapter.calculate(geo_points)
    end

    it 'should use a default service path when none is given' do
      request.should_receive(:url).with('/routing/7.2/calculateroute.json')

      adapter = described_class.new(options)
      adapter.calculate(geo_points)
    end

    it 'should allow setting the parser' do
      parser_class.should_receive(:new)

      adapter = described_class.new(options.merge(:parser => parser_class))
      adapter.calculate(geo_points)
    end

    it 'should use a default parser when none is given' do
      Routing::Parser::HereSimple.should_receive(:new).and_return(parser)

      options.delete(:parser)
      adapter = described_class.new(options)
      adapter.calculate(geo_points)
    end

    it 'ignores unknown options' do
      expect { described_class.new(:hello => "world") }.to_not raise_error
    end
  end

  describe '#calculate' do
    it 'passes the response to the parser' do
      response.stub(:body => '...')
      parser_class.should_receive(:new).with('...')
      adapter.calculate(geo_points)
    end

    it 'should return the parser\'s result' do
      result = [double, double, double]
      parser.stub(:to_geo_points => result)
      adapter.calculate(geo_points).should be(result)
    end

    it 'should convert the geo points into a compatible format' do
      request.should_receive(:params=).with hash_including({
        'waypoint0' => 'geo!1,2',
        'waypoint1' => 'geo!3,4',
        'waypoint2' => 'geo!5,6'
      })
      adapter.calculate(geo_points)
    end
  end
end
