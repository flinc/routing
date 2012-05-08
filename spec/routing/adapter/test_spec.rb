require 'spec_helper'

describe Routing::Adapter::Test do

  context 'creating a new instance' do

    it 'can be instantiated without arguments' do
      expect { Routing::Adapter::Test.new }.to_not raise_error
    end

  end

  describe '#calculate' do
    
    let(:geo_points){ [Struct.new(:lat, :lng).new(1, 2), Struct.new(:lat, :lng).new(3, 4), Struct.new(:lat, :lng).new(5, 6)] }
    
    it 'returns the same geo points that are passed to the method' do
      subject.calculate(geo_points).should == geo_points
    end
    
  end

end