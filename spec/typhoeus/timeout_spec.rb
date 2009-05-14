require File.dirname(__FILE__) + '/../spec_helper'
require 'pp'


class TimeoutTestClass
	  include Typhoeus
	  remote_defaults :on_success => lambda {|response| response.body.to_i},
	                  :on_failure => lambda {|response| puts "error code: #{response.code}"; "fail"},
	                  :base_uri   => "http://localhost:3002"

	  define_remote_method :go, :path => '/', :timeout=>500
end

describe Typhoeus do

  before(:all) do
    @pid = start_count_server(3002,1000)
    Typhoeus.init_easy_object_pool
  end

  after(:all) do
    stop_method_server(@pid)
  end


  describe "simple timeout" do
    it "should timeout when timeout is set less than tolerance" do
	e = Typhoeus::Easy.new
        e.url = "http://localhost:3002"
        e.method = :get
	e.timeout = 200
        e.perform

	e.timed_out?.should == true
    end

    it "should not timeout when timeout is set greater than tolerance" do
	e = Typhoeus::Easy.new
        e.url = "http://localhost:3002"
        e.method = :get
        e.timeout = 1500
        e.perform

	e.timed_out?.should == false
    end
  end	


  describe "retry logic" do  
     it "should pass after 2 retries" do
       x = TimeoutTestClass.go :timeout=>100
       x.should == 3
     end
     it "should fail as normal when retries fail" do
       x = TimeoutTestClass.go :timeout=>100
       x.should == "fail"
     end
  end

end