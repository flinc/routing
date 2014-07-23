require 'spec_helper'

describe Routing do
  context 'creating a new instance' do
    let(:adapter) { double }

    it 'can be called without arguments' do
      expect { Routing.new }.to_not raise_error
    end

    it 'uses the default adapter, if no adapter is passed' do
      expect(described_class.default_adapter).to receive(:calculate)
      subject.calculate(double, double)
    end

    it 'takes the passed adapter, if given' do
      expect(adapter).to receive(:calculate)
      described_class.new(adapter).calculate(double, double)
    end

    it 'takes a configuration block' do
      expect { described_class.new { throw :called } }.to throw_symbol(:called)
    end

    it 'passes itself to the configuration block' do
      described_class.new { |r| expect(r).to be_instance_of(described_class) }
    end
  end

  describe '#calculate' do
    let(:geo_points) { [double(lat: 1, lng: 2), double(lat: 3, lng: 4), double(lat: 5, lng: 6)] }
    let(:adapter) { double(calculate: geo_points) }

    subject { described_class.new(adapter) }

    it 'should call the adapter' do
      expect(adapter).to receive(:calculate).with(geo_points)
      subject.calculate(geo_points)
    end

    it 'should call each middleware in the given order' do
      first_middleware = double(Routing::Middleware)
      expect(first_middleware).to receive(:calculate).
        with(geo_points).and_yield(geo_points)

      second_middleware = double(Routing::Middleware)
      expect(second_middleware).to receive(:calculate).
        with(geo_points)

      allow(subject).to receive(:middlewares).and_return([first_middleware, second_middleware])

      subject.calculate(geo_points)
    end
  end

  context 'using the middleware' do
    it 'has an empty array of middlewares by default' do
       expect(subject.middlewares).to be_an(Array)
       expect(subject.middlewares.size).to eq(0)
    end

    describe '#use' do
      it 'appends the new middleware to the stack' do
        subject.use(:hello)
        subject.use(:world)
        expect(subject.middlewares).to eq([:hello, :world])
      end
    end
  end
end
