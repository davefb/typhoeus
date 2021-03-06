require File.dirname(__FILE__) + '/../spec_helper'

describe Typhoeus::RemoteProxyObject do
  before(:each) do
    @easy = Typhoeus::Easy.new
    @easy.method = :get
    @easy.url    = "http://localhost:3001"
  end
      
  before(:all) do
    @pid = start_method_server(3001)
  end
  
  after(:all) do
    stop_method_server(@pid)
  end
  
  it "should take a caller and call the clear_memoized_proxy_objects" do
    clear_proxy = lambda {}
    clear_proxy.should_receive(:call)
    response = Typhoeus::RemoteProxyObject.new(clear_proxy, @easy)
    response.code.should == 200
  end

  it "should take an easy object and return the body when requested" do
    response = Typhoeus::RemoteProxyObject.new(lambda {}, @easy)
    @easy.response_code.should == 0
    response.code.should == 200
  end
  
  it "should perform requests only on the first access" do
    response = Typhoeus::RemoteProxyObject.new(lambda {}, @easy)
    response.code.should == 200
    Typhoeus.should_receive(:perform_easy_requests).exactly(0).times
    response.code.should == 200
  end
  
  it "should call the on_success method with an easy object and proxy to the result of on_success" do
    klass = Class.new do
      def initialize(r)
        @response = r
      end
      
      def blah
        @response.code
      end
    end
    
    k = Typhoeus::RemoteProxyObject.new(lambda {}, @easy, :on_success => lambda {|e| klass.new(e)})
    k.blah.should == 200
  end
  
  it "should call the on_failure method with an easy object and proxy to the result of on_failure" do
    klass = Class.new do
      def initialize(r)
        @response = r
      end
      
      def blah
        @response.code
      end
    end
    @easy.url = "http://localhost:3002" #bad port
    k = Typhoeus::RemoteProxyObject.new(lambda {}, @easy, :on_failure => lambda {|e| klass.new(e)})
    k.blah.should == 0
  end
end