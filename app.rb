# Bundler
require 'rubygems'
require 'bundler/setup'
Bundler.require :default

require 'sinatra/reloader' if development?
require 'sinatra/cookies'

# config
require_relative 'config.rb'

# Application specific libraries
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |f| require f }



get '/' do
	@users = User.all
	haml :index
end

get '/admin' do
	if is_admin
		@tags = Tag.all
		haml :admin
	else
		haml :login
	end
end

get '/tags' do
	redirect to("/admin") unless is_admin
	@tags = Tag.all
	haml :tags
end

post '/admin' do
	if params[:password] == $password
		cookies[:admin_password] = params[:password]
		redirect to "/admin"
	else
		haml :login
	end
end

get '/logout' do
	cookies[:admin_password] = ""
	redirect to '/'
end

post '/add_tag' do
	redirect to "/admin" unless is_admin

	@tag = Tag::new(params)
	@tag.generate_code
	if @tag.save
		redirect to "/admin"
	else
		"Failed to save tag, #{@tag.errors.inspect}"
	end
end

get '/qr/:code' do 
end
