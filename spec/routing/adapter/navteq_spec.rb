require 'spec_helper'

describe Routing::Adapter::Navteq do

  context 'creating a new instance' do

    it 'can be instantiated without arguments' do
      expect { Routing::Adapter::Navteq.new }.to_not raise_error
    end

    it 'sets the host in its options' do
      described_class.new(:host => "new_host").host.should == "new_host"
    end

    it 'sets the default params in its options' do
      params = { :hello => "world" }
      described_class.new(:default_params => params).default_params == params
    end

    it 'ignores unknown options' do
      expect { described_class.new(:hello => "world") }.to_not raise_error
    end

  end

  its(:service_path){ should be_a String }

  its(:default_params){ should be_a Hash }

  describe '#connection' do

    it 'returns a faraday connection' do
      subject.send(:connection).should be_a Faraday::Connection
    end

  end

  describe '#calculate' do
    pending
  end

  describe '#get' do
    pending
  end

  describe '#geo_points_to_params' do

    let(:geo_points) { [stub(:lat => 1, :lng => 2), stub(:lat => 3, :lng => 4), stub(:lat => 5, :lng => 6)] }
    let(:params){ subject.send(:geo_points_to_params, geo_points) }

    it 'creates a hash with enumerated waypoint keys and the navteq special geo! syntax as values' do
      params['waypoint0'].should == 'geo!1,2'
      params['waypoint1'].should == 'geo!3,4'
      params['waypoint2'].should == 'geo!5,6'
    end

  end

end