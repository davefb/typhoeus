# A simple class that returns the number of times the server has been called, based off DelayFixtureServer
require 'rubygems'
require 'eventmachine'
require 'evma_httpserver'
require File.dirname(__FILE__) + '/generic_server.rb'


class CountServer   < GenericServer
	@@num_times_called = 0

	def self.reset_num_times_called
	    @@num_times_called  = 0;
	end	

	def generate_sleep_time
	   if @@num_times_called > 2
		0.001
	   else
		super
	   end
        end	

        def generate_content
	   @@num_times_called  += 1;	   
	   return @@num_times_called
        end
end


