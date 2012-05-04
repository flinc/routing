require 'spec_helper'

describe Routing::GeoPoint do

  context 'creating a new instance' do

    it 'can be instantiated without arguments' do
      expect { described_class.new }.to_not raise_error
    end

    context 'initialized with attributes' do

      subject { described_class.new(:lat => 1, :lng => 2) }

      it 'ignores passed attributes that dont exist' do
        expect { described_class.new(:hello => :world) }.to_not raise_error
      end

      it 'will set all passed attributes on the instance' do
        subject.lat.should be(1)
        subject.lng.should be(2)
      end
    end

  end

  [:lat, :lng, :original_lat, :original_lng, :relative_time, :distance, :waypoint].each do |attribute|

    describe "##{attribute}" do
      it{ should respond_to attribute }
    end

  end

  describe '#waypoint?' do
    it{ should_not be_waypoint }

    context 'when a truthy waypoint value is set' do

      before(:each) do
        subject.waypoint = true
      end

      it{ should be_waypoint }

    end

    context 'when a falsy waypoint value is set' do

      before(:each) do
        subject.waypoint = false
      end

      it{ should_not be_waypoint }

    end
  end

end