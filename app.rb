require 'rubygems'
require 'sinatra'
# require 'sinatra/json'
require 'mongoid'
require 'json'
# this is now using this https://github.com/treeder/rack-flash which is
# installed in the Gemfile as 'rack-flash3'
require 'rack-flash'
require 'digest/sha1'
require 'sinatra/reloader' if :development?

require_relative 'lib/helpers'
Dir[File.dirname(__FILE__) + '/models/*'].each {|file| require_relative file }

Mongoid.load!("config/mongoid.yml")

configure :test do
  puts 'Test configuration in use'
  puts 'env name = ' + Mongoid::Config::Environment.env_name.to_s
end
configure :development do
  puts 'Development configuration in use for cantoflash'
end
configure :production do
  puts 'Production configuration in use for cantoflash'
  disable :raise_errors
  disable :show_exceptions
end
set :mongo_logfile, File.join("log", "mongo-driver-#{settings.environment}.log")

# we don't want to use session based cookies - in fact the auth.platform
# doesn't need to use sessions at all
# use Rack::Session::Cookie, :secret => 'thisisasecret'
# enable :sessions
# use Rack::Flash

configure :production, :test do
  not_found do
    content_type :json
    {:error => "not-found"}.to_json
  end

  error do
    content_type :json
    {:error => "server-error"}.to_json
  end
end

configure :development do
  not_found do
    content_type :json
    {:error => "not-found"}.to_json
  end
end

get '/' do
  content_type :json
  { :url => '/' }.to_json
end

get '/tokens/:token?' do
  if params["app-key"].nil? || params["app-key"] != "5555"
    halt 422
  end
  token = Token.where(:value => params[:token]).first
  if token.nil?
    content_type :json
    { :value => false }.to_json
  else
    content_type :json
    {
      :value => token.value,
      :uid => token.uid,
      :created_at => token.created_at
    }.to_json
  end
end

post '/tokens/new' do
  # see http://developer.github.com/v3/#client-errors
  if params[:username].nil? ||
     params[:password].nil? ||
     params[:callback].nil?
    # you only need status here because it calls not_found which stops the
    # execution
    # status 404
    # but you need halt here to stop the execution
    halt 422
  end
  @username = params[:username]
  @password = params[:password]
  @callback = params[:callback]

  user = User.where(:username => params[:username], :password => params[:password]).first

  # if username/password are correct, create a token and set it in a
  # domain-wide cookie
  if user.nil?
    # this needs to redirect back to the form instead of a 404
    # halt 404
    response.set_cookie("error",
                        :value => "username or password incorrect",
                        :domain => ".platform.local",
                        :path => "/")
    redirect request.referrer
  end

  token = generate_token(user)
  response.set_cookie("token",
                      :value => token,
                      :domain => ".platform.local",
                      :path => "/")

  redirect @callback
end

