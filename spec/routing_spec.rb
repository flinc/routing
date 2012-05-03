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

  context 'calculating a route through the middleware stack' do
    pending
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