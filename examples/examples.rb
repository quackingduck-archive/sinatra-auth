require 'exemplor'
require 'pow'

require 'rack/test'
require 'sinatra/base'
require Pow!('../lib/sinatra/auth')

eg "Username and password" do
  app do
    auth :username => 'myles',
         :password => 'p4ssw3rd'
  
    get('/') { 'sekrets' }
  end
  
  check_auth
end

eg "Username, password and realm name" do
  app do
    auth :username => 'myles', 
         :password => 'p4ssw3rd', 
         :realm => 'Admin'
    
    get('/') { 'sekrets' }
  end
  
  check_auth :realm => 'Admin'
end

eg "Non-root scope" do
  app do
    auth '/admin',
         :password => 'p4ssw3rd'
    
    get('/') { 'not secret' }
    get('/admin') { 'sekrets' }
    get('/admin/foo') { 'sekrets' }
  end
  
  Check(get('/').body).is('not secret')
  check_auth '/admin'
  check_auth '/admin/foo'
end

eg "Just password (any user name valid)" do
  app do
    auth :password => 'p4ssw3rd'
    
    get('/') { 'sekrets' }
  end
  
  check_auth
end

eg "Block for authentication" do
  app do
    auth do |username,password|
      username == 'myles' && password == 'p4ssw3rd'
    end
    
    get('/') { 'sekrets' }
  end
  
  check_auth
end

# --

eg.helpers do
  
  include Rack::Test::Methods
  
  def check_auth(path_or_options = '/', options = {})
    options = case path_or_options
    when Hash: {:path => '/'}.merge(path_or_options)
    when String: options.merge(:path => path_or_options)
    end
    
    allowed = get options[:path], {}, basic_auth
    Check(allowed.status).is(200)
    denied  = get options[:path]
    Check(denied.status).is(401)
    Check(denied['WWW-Authenticate']).is(%{Basic realm="#{options[:realm] || 'Protected Area'}"})
  end
  
  def basic_auth(user="myles", password="p4ssw3rd")
    credentials = ["#{user}:#{password}"].pack("m*")

    { "HTTP_AUTHORIZATION" => "Basic #{credentials}" }
  end
  
  def app(&blk)
    if blk
      @app = Class.new Sinatra::Application # Sinatra::Base doesn't work
      @app.set :environment, :test
      @app.class_eval &blk
    end
    @app
  end
  
end