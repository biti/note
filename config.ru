require 'rubygems'
require 'sinatra'

Sinatra::Base.set :views, File.join(File.dirname(__FILE__), 'views')
Sinatra::Base.set :run, false
Sinatra::Base.set :env, ENV['RACK_ENV']

require 'main'
run Sinatra::Application

