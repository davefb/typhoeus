# this server simply is for testing out the different http methods. it echoes back the passed in info
require File.dirname(__FILE__) + '/generic_server.rb' 
class MethodServer  < GenericServer
 
  def generate_content
    return request_params + "\n#{@http_post_content}"
  end

  def request_params
    %w( PATH_INFO QUERY_STRING HTTP_COOKIE IF_NONE_MATCH CONTENT_TYPE REQUEST_METHOD REQUEST_URI ).collect do |param|
      "#{param}=#{ENV[param]}"
    end.join("\n")
  end
  
end
