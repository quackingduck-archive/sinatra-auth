Simple authentication for Sinatra

Simplest case:
    
    auth :password => 'p4ssw3rd'

Which is shorter than calling the rack middleware:
    
    use Rack::Auth::Basic do |_, password|
      password == 'p4ssw3rd'
    end

Also supports scoping:
    
    auth '/admin',
      :username => 'myles',
      :password => 'p4ssw3rd'

... and some other options. See examples.rb