require 'spec_helper'

describe Routing::Adapter::Navteq do

  let(:response) { mock(:response).as_null_object }
  let(:request) { mock(:request).as_null_object }
  let(:connection) { mock(:connection).as_null_object }
  let(:parser_class) { mock(:parser_class, :new => parser) }
  let(:parser) { mock(:parser).as_null_object }

  let(:options) { { :host => 'http://example.com', :parser => parser_class } }

  let(:geo_points) { [stub(:lat => 1, :lng => 2), stub(:lat => 3, :lng => 4), stub(:lat => 5, :lng => 6)] }


  subject { described_class.new(options) }

  before do
    connection.stub(:get).and_yield(request).and_return(response)
    Faraday.stub(:new).and_return(connection)
  end

  after { subject.calculate(geo_points) }

  context 'creating a new instance' do
    it 'can be instantiated without arguments' do
      expect { described_class.new }.to_not raise_error
    end

    it 'allows setting the host' do
      Faraday.should_receive(:new).with(:url => 'http://other.com')
      options.merge!(:host => 'http://other.com')
    end

    it 'allows setting the default params' do
      params = { :hello => "world" }
      options.merge!(:default_params => params)
      request.should_receive(:params=).with(hash_including(params))
    end

    it 'should allow setting the service path' do
      options.merge!(:service_path => '/some/path.json')
      request.should_receive(:url).with('/some/path.json')
    end

    it 'should use a default service path when none is given' do
      request.should_receive(:url).with('/routing/6.2/calculateroute.json')
    end

    it 'should allow setting the parser' do
      options.merge!(:parser => parser_class)
      parser_class.should_receive(:new)
    end

    it 'should use a default parser when none is given' do
      options.delete(:parser)
      Routing::Parser::NavteqSimple.should_receive(:new).and_return(parser)
    end

    it 'ignores unknown options' do
      expect { described_class.new(:hello => "world") }.to_not raise_error
    end
  end

  describe '#calculate' do
    it 'passes the response body to the parser' do
      response.stub(:body => '...')
      parser_class.should_receive(:new).with('...')
    end

    it 'should return the parser\'s result' do
      result = [double, double, double]
      parser.stub(:to_geo_points => result)
      subject.calculate(geo_points).should be(result)
    end

    it 'should convert the geo points into a compatible format' do
      request.should_receive(:params=).with hash_including({
        'waypoint0' => 'geo!1,2',
        'waypoint1' => 'geo!3,4',
        'waypoint2' => 'geo!5,6'
      })
    end
  end
end