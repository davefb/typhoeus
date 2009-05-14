# this server simply accepts requests and blocks for a passed in interval before returning a passed in reqeust value to
# the client
require File.dirname(__FILE__) + '/generic_server.rb'

class DelayFixtureServer  < GenericServer

  def generate_content
     return @response_fixture
  end 
  
  def self.response_fixture
    @response_fixture ||= "whatever"
  end
  
  def self.response_fixture=(val)
    @response_fixture = val
  end

end

