# this server simply accepts requests and blocks for a passed in interval before returning a passed in reqeust value to
# the client
require 'rubygems'
require 'eventmachine'
require 'evma_httpserver'
 
class GenericServer  < EventMachine::Connection
  include EventMachine::HttpServer

  def generate_content
     raise NotImplementedError
  end

  def generate_sleep_time
     self.class.sleep_time
  end
 
  def process_http_request
    EventMachine.stop if ENV["PATH_INFO"] == "/die"
    resp = EventMachine::DelegatedHttpResponse.new( self )
    
    # Block which fulfills the request

    operation = proc do
      resp.status = 200
      resp.content = generate_content
      sleep generate_sleep_time
    end

   

    # Callback block to execute once the request is fulfilled
    callback = proc do |res|
      resp.send_response
    end
    

    # Let the thread pool (20 Ruby threads) handle request
    EM.defer(operation, callback)
  end

  def self.sleep_time
     @sleep_time ||= 0	
  end

  def self.sleep_time=(val)
     @sleep_time = val;     
  end

  def self.response_delay
    @response_delay ||= 0
  end

  def self.response_delay=(val)
    @response_delay = val
  end
  
  def self.reponse_number
    @response_number
  end
  
  def self.response_number=(val)
    @response_number = val
  end

end

