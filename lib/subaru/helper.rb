require 'json'
require 'subaru/d-xytronix'


module Subaru
  
  # Sinatra helper
  module Helper

    # Convert object into JSON.
    def json_with_object(object, opts = {pretty: settings.subaru_config[:global][:pretty_json]})
      return '{}' if object.nil?
      if opts[:pretty] == true
        opts = {
          indent: '  ',
          space: ' ',
          object_nl: "\n",
          array_nl: "\n"
        }
      end
      JSON.fast_generate(object, opts)
    rescue => e
      puts e.message
      raise
    end

    # Validate auth token, if configured.
    def valid_token?(token, method = :any)
      tokens = settings.subaru_config[:global][:auth_tokens][method]
      return true if tokens.nil?
      tokens.include?(token)
    end

    # Create device object with name
    # @param name [String]
    # @return [Object]
    def device_with_name(name)
      c = settings.subaru_config[:devices][name]
      return Object.const_get("Subaru::Definitions::#{c[:definition]}").new(c) if c
    rescue => e
      puts e.message
      return nil
    end

  end

end

