require 'sinatra/base'
require 'yaml'
require 'subaru/helper'


module Subaru

  # The Sinatra server
  class Server < Sinatra::Base

    def self.run!(opts = {})
      unless opts[:config]
        puts "Configuration file required. Example:\n\n"
        puts IO.read(File.expand_path('../config_temp.yml', __FILE__))
        abort
      end
      config = YAML.load_file(opts[:config])
      super(bind: opts[:address], port: opts[:port], subaru_config: config)
    end

    helpers Helper

    configure do
      disable :static
    end

    before do
      halt 401 unless valid_token?(params[:auth])
    end

    get '/:device' do |device|
      dev = device_with_name(device)
      halt 404 unless dev
      res = dev.read
      halt 500 unless res
      json_with_object(res)
    end

    put '/:device' do |device|
      dev = device_with_name(device)
      halt 404 unless dev
      request.body.rewind  # in case someone already read it
      res = dev.write(request.body.read)
      halt 500 unless res
      json_with_object(res)
    end

    not_found do
      json_with_object({message: 'Not found.'})
    end

    error 401 do
      json_with_object({message: 'Auth required.'})
    end

    error do
      status 500
      json_with_object({message: 'Sorry, internal error.'})
    end

  end

end
