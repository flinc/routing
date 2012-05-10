require 'spec_helper'

describe Routing do

  context 'creating a new instance' do

    let(:adapter) { mock }

    it 'can be called without arguments' do
      expect { Routing.new }.to_not raise_error
    end

    it 'uses the default adapter, if no adapter is passed' do
      described_class.default_adapter.should_receive(:calculate)
      subject.calculate(stub, stub)
    end

    it 'takes the passed adapter, if given' do
      adapter.should_receive(:calculate)
      described_class.new(adapter).calculate(stub, stub)
    end

    it 'takes a configuration block' do
      expect { described_class.new { throw :called } }.to throw_symbol(:called)
    end

    it 'passes itself to the configuration block' do
      described_class.new { |r| r.should be_instance_of(described_class) }
    end

  end

  describe '#calculate' do
    let(:geo_points) { [stub(:lat => 1, :lng => 2), stub(:lat => 3, :lng => 4), stub(:lat => 5, :lng => 6)] }
    let(:adapter) { mock(:calculate => geo_points) }

    subject { described_class.new(adapter) }

    it 'should call the adapter' do
      adapter.should_receive(:calculate).with(geo_points)
      subject.calculate(geo_points)
    end

    it 'should call each middleware in the given order' do
      first_middleware = double(Routing::Middleware)
      first_middleware.should_receive(:calculate).
        with(geo_points).and_yield(geo_points)

      second_middleware = double(Routing::Middleware)
      second_middleware.should_receive(:calculate).
        with(geo_points)

      subject.stub(:middlewares).and_return([first_middleware, second_middleware])

      subject.calculate(geo_points)
    end
  end

  context 'using the middleware' do

    it 'has an empty array of middlewares by default' do
       subject.middlewares.should be_an(Array)
       subject.should have(0).middlewares
    end

    describe '#use' do
      it 'appends the new middleware to the stack' do
        subject.use(:hello)
        subject.use(:world)
        subject.middlewares.should == [:hello, :world]
      end
    end

    describe '#middlewares' do
      it 'replaces all middlewares' do
        subject.use(:original)
        subject.middlewares = :first, :second
        subject.middlewares.should == [:first, :second]
      end
    end
  end
end