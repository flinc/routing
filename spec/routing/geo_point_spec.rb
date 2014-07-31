require 'spec_helper'

describe Routing::GeoPoint do
  context 'creating a new instance' do
    it 'can be instantiated without arguments' do
      expect { described_class.new }.to_not raise_error
    end

    describe '#fetch' do
      subject(:geo_point) { described_class.new }

      it 'raises if the key is not a struct member and no default has been specified' do
        expect { geo_point.fetch(:unknown) }.to raise_error(KeyError)
      end

      it 'returns the second argument or the return value of an optional block when #fetch is invoked with a key that is not a struct member (the block has precedence)' do
        expect(geo_point.fetch(:unknown, 42)).to eq(42)
        expect(geo_point.fetch(:unknown, 42) { 13 }).to eq(13)
      end
    end

    context 'initialized with attributes' do
      subject(:geo_point) { described_class.new(:lat => 1, :lng => 2) }

      it "should respond with 1 when #lat is invoked" do
        expect(geo_point.lat).to eq(1)
      end

      it "should respond with 1 when #fetch(:lat) is invoked" do
        expect(geo_point.fetch(:lat)).to eq(1)
      end

      it "should respond with 2 when #lng is invoked" do
        expect(geo_point.lng).to eq(2)
      end

      it "should respond with 2 when #fetch(:lng) is invoked" do
        expect(geo_point.fetch(:lng)).to eq(2)
      end

      it 'ignores passed attributes that dont exist' do
        expect { described_class.new(:hello => :world) }.to_not raise_error
      end

    end
  end

  [:lat, :lng, :original_lat, :original_lng, :relative_time, :distance, :waypoint].each do |attribute|
    it { should respond_to attribute }
  end

  describe '#waypoint?' do
    it { should_not be_waypoint }

    context 'when a truthy waypoint value is set' do
      before { subject.waypoint = true }
      it { should be_waypoint }
    end

    context 'when a falsy waypoint value is set' do
      before { subject.waypoint = false }
      it { should_not be_waypoint }
    end
  end
end
