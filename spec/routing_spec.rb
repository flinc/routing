require 'spec_helper'

describe Routing do

  context 'creating a new instance' do

    let(:configured_routing) do
      Routing.new do |routing|
        routing.adapter = "OVERWRITE_ADAPTER"
      end
    end

    it 'can be called without arguments' do
      expect { Routing.new }.to_not raise_error
    end

    it 'uses the default adapter, if no adapter is passed' do
      subject.adapter.should == described_class.default_adapter
    end

    it 'takes the passed adapter, if given' do
      Routing.new(:my_adapter).adapter.should == :my_adapter
    end

    it 'takes a configuration block' do
      configured_routing.adapter.should == "OVERWRITE_ADAPTER"
    end

  end

  describe '#calculate' do
    let(:geo_points){ [Struct.new(:lat, :lng).new(1, 2), Struct.new(:lat, :lng).new(3, 4), Struct.new(:lat, :lng).new(5, 6)] }
    let(:adapter) { mock(:calculate => geo_points) }

    before do
      subject.stub(:adapter).and_return(adapter)
    end

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

    describe '#use an additional middleware' do

      before(:each) do
        subject.use(:hello)
        subject.use(:world)
      end

      it 'appends the new middleware to the stack' do
        subject.middlewares.should == [:hello, :world]
      end
    end

    describe '#middlewares' do
      before(:each) do
        subject.middlewares = :first, :second
      end

      it 'replaces all middlewares' do
        subject.middlewares.should == [:first, :second]
      end
    end

  end

end