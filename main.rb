require 'rubygems'
require 'sinatra'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/vendor/sequel'
require 'sequel'

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'setting'

configure do
	Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://note.db')
end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'note'

error do
	e = request.env['sinatra.error']
	puts e.to_s
	puts e.backtrace.join("\n")
	"Application error"
end

error 403 do
  'Access forbidden'
end

helpers do
	def partial(template, locals = {})
		erb(template, :layout => false, :locals => locals)
	end

	def admin?
		request.cookies[Setting.admin_cookie_key] == Setting.admin_cookie_value
	end

	def auth
    unless admin?
		  status 401
		  body 'Not authorized'	
    end
	end
end

layout 'layout'

get '/' do
  redirect '/notes'
end

get '/auth' do
	erb :auth
end

post '/auth' do
	if params[:password] == Setting.admin_password
	  response.set_cookie(Setting.admin_cookie_key, Setting.admin_cookie_value) 
    redirect '/'
	end
	redirect '/auth'
end

get '/notes/new' do
	auth
	erb :edit, :locals => { :note => Note.new, :url => '/notes' }
end

post '/notes' do
	auth
	note = Note.new params
	note.created_at = Time.now
	note.save
	redirect "/notes"
end

get '/notes' do
  auth
	notes = Note.filter(:body.like("%#{params[:keyword]}%"))
	            .order(:created_at.desc, :id.desc)
							.limit(20)
	erb :index, :locals => { :notes => notes }, :layout => false
end

