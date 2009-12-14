task :default => :examples

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name     = "sinatra-auth"
    s.homepage = "http://github.com/quackingduck/sinatra-auth"
    s.summary  = "Simple authentication for sinatra"
    s.email    = "myles@myles.id.au"
    s.authors  = ["Myles Byrne"]
    
    s.add_dependency 'sinatra', '>= 0.9.4'
    s.add_development_dependency 'exemplor', '>= 2010.0.0'
    s.add_development_dependency 'rack-test', '0.4.0'
    s.add_development_dependency 'pow', '0.2.2'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Install jeweler to build gem"
end

task(:examples) { ruby "examples.rb" }
task :test => :examples

task :tag_version do 
  version = File.read('VERSION')
  system "git tag -a v#{version} -m v#{version}"
end