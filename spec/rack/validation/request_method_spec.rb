require 'spec_helper'
require 'goliath/rack/validation/request_method'

describe Goliath::Rack::Validation::RequestMethod do
  before(:each) do
    @app = mock('app').as_null_object
  end

  it 'accepts an app' do
    lambda { Goliath::Rack::Validation::RequestMethod.new('my app') }.should_not raise_error(Exception)
  end

  describe 'with defaults' do
    before(:each) do
      @env = {}
      @rm = Goliath::Rack::Validation::RequestMethod.new(@app, ['GET', 'POST'])
    end

    it 'raises error if method is invalid' do
      @env['REQUEST_METHOD'] = 'fubar'
      lambda { @rm.call(@env) }.should raise_error(Goliath::Validation::Error)
    end

    it 'allows valid methods through' do
      @env['REQUEST_METHOD'] = 'GET'
      lambda { @rm.call(@env) }.should_not raise_error
    end

    it 'returns app status, headers and body' do
      app_headers = {'Content-Type' => 'asdf'}
      app_body = {'a' => 'b'}
      @app.should_receive(:call).and_return([200, app_headers, app_body])

      @env['REQUEST_METHOD'] = 'POST'

      status, headers, body = @rm.call(@env)
      status.should == 200
      headers.should == app_headers
      body.should == app_body
    end
  end

  it 'accepts methods on initialize' do
    rm = Goliath::Rack::Validation::RequestMethod.new('my app', ['GET', 'DELETE', 'HEAD'])
    rm.methods.should == ['GET', 'DELETE', 'HEAD']
  end
end