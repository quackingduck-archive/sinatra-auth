gem "sr-mg", "0.0.2"

task :default => :test

desc "Run tests"
task :test do
  ruby "-r rubygems test/authorization_test.rb"
end

begin
  require "mg"
  MG.new("sinatra-authorization.gemspec")
rescue LoadError
end
