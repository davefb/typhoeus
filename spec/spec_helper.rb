require "rubygems"
require "spec"

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

require "lib/typhoeus"

# local servers for running tests
require File.dirname(__FILE__) + "/servers/method_server.rb"
require File.dirname(__FILE__) + "/servers/count_server.rb"

def start_server(port, klass, sleep = 0)
  # keep consistency with the timeout definition for 
  #  curl, which is in ms.                      
  klass.sleep_time = sleep/1000
  pid = Process.fork do
    EventMachine::run {
      EventMachine.epoll
      EventMachine::start_server("0.0.0.0", port, klass)
    }
  end

  sleep 0.2
  pid
end

def start_method_server(port, sleep = 0)
   start_server(port,MethodServer,sleep)
end

def start_count_server(port, sleep = 0)
   CountServer.reset_num_times_called
   start_server(port,CountServer,sleep)
end

# TODO: rename and refactor
def stop_method_server(pid)
   Process.kill("HUP", pid)
end
