module Sinatra
  
  module AuthDSL

    # Only call this. Everything else is implementation. See examples.rb for usuage examples
    def auth(*args, &blk)
      auths << Auth.new(*args,&blk)
      setup_authorization_filter if auths.size == 1
    end

    def setup_authorization_filter
      before do
        authenticator = self.class.auths.reverse.find { |auth| auth.protecting?(request.path_info) }
        authenticate_with authenticator if authenticator
      end
    end

    def auths
      @auths ||= []
    end
    
    def self.registered(app)
      app.helpers AuthHelpers
    end

  end
  
  module AuthHelpers

    def authenticate_with(authenticator)
      auth = Rack::Auth::Basic::Request.new(request.env)
      unauthorized!(authenticator.realm) unless auth.provided?
      bad_request! unless auth.basic?
      unauthorized!(authenticator.realm) unless authenticator.authorized?(*auth.credentials)
    end

    def unauthorized!(realm)
      response["WWW-Authenticate"] = %(Basic realm="#{realm}")
      throw :halt, [ 401, 'Authorization Required' ]
    end

    def bad_request!
      throw :halt, [ 400, 'Bad Request' ]
    end
  end
  
  
  class Auth
    
    def self.new(*args, &blk)
      super(parse_args(args, &blk))
    end
    
    def self.parse_args(args,&blk)
      conf = {}
      conf[:auth_proc] = blk
      case args.size
      when 1
        conf.merge!(args.first)
      when 2
        conf[:scope] = args.first
        conf.merge!(args.last)
      end
      conf
    end
    
    attr_reader :conf
    
    def initialize(conf)
      @conf = conf
    end
    
    def authorized?(usename,password)
      conf[:auth_proc] ||= proc { |u,p| self.valid_user?(u) && self.password == p }
      return conf[:auth_proc].call(usename,password)
    end
    
    def protecting?(path)
      scope_pattern =~ path
    end
    
    def valid_user?(username)
      return true if conf[:username].nil?
      conf[:username] == username
    end
    
    def password
      conf[:password]
    end
    
    def realm
      conf[:realm] ||= "Protected Area"
    end
    
    def scope_pattern
      @scope_pattern ||= case conf[:scope]
        when nil:    //
        when String: /^#{conf[:scope]}/
        else;        conf[:scope]
        end
    end
  end
  
  register AuthDSL
end