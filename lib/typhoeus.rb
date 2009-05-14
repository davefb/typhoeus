$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'cgi'
require 'digest/sha2'
require 'typhoeus/easy'
require 'typhoeus/multi'
require 'typhoeus/native'
require 'typhoeus/filter'
require 'typhoeus/remote_method'
require 'typhoeus/remote'
require 'typhoeus/remote_proxy_object'
require 'typhoeus/response'
require 'pp'

module Typhoeus
  VERSION = "0.0.8"
  
  def self.easy_object_pool
    @easy_objects ||= []
  end

  def self.easy_object_pool_out
    @easy_objects_out ||= []
  end

  
  def self.init_easy_object_pool
    20.times do
      easy_object_pool << Typhoeus::Easy.new
    end
  end
  
  def self.release_easy_object(easy)
    easy.reset
    easy_object_pool << easy
  end
  
  def self.get_easy_object
     # TODO: Currently this will break the retry logic
     #         this could be fixed by having auxilary array of all the outstanding handles 
     #         or writing some native code to get it from curl
    if easy_object_pool.empty?
      Typhoeus::Easy.new
    else
      ret = easy_object_pool.pop
      easy_object_pool_out << ret
      ret
    end
  end
  
  def self.add_easy_request(easy_object)
    Thread.current[:curl_multi] ||= Typhoeus::Multi.new
    Thread.current[:curl_multi].add(easy_object)
  end

  def self.perform_easy_requests
    while true
      Thread.current[:curl_multi].perform
      retry_backoff = [];

      # This seems to be the correct place to have the retry logic
      #   rather than in the remote_proxy_class. This way, we can
      #   retry all the requests in parallel until we reach the re-
      #   try limit or succeed
      easy_object_pool_out.each do |easy|
        if easy.timed_out? and not easy.max_retries?
          easy.increment_retries;
          easy.increment_backoff;
          add_easy_request(easy);
	  retry_backoff << easy.backoff;
        end
      end

      if retry_backoff.size > 0
        # This is a bit of a hack, ideally, we'd be waiting indivually. 
        puts "Sleeping"
        sleep retry_backoff.max
        perform_easy_requests
      else 
        break
      end
    end
  end
end
