# encoding: utf-8

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

$flash = Hash.new


get '/' do
	@users = User.all
	haml :index
end

get '/admin' do
	if is_admin
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

get '/delete_tag/:id' do |id|
	redirect to "/admin" unless is_admin

	@tag = Tag.find_by_id(id)
	@tag.delete
	$flash["success"] = "Tagen raderad"

	haml :admin
end

get '/u' do
	if authorize
		haml :my_page
	else
		haml :create_user
	end
end

post '/create_user' do
	@code = params[:code]
	if User.find_by_name(params[:name])
		$flash["error"] = "Namnet är upptaget, kom på nått nytt för fan!"
		haml :create_user
	else
		@user = User.create(:name=>params[:name])
		cookies[:user_id] = @user.id
		redirect to("/qr/#{@code}")
	end
end

get '/qr/:code' do
	@code = params[:code]
	@tag = Tag.find_by_code(@code)
	$flash["error"] = "Ogiltlig kod." unless @tag
	if authorize
		if @tag
			if @user.add_code(@tag)
				$flash["success"] = "Taggade #{@tag.name}"
			else
				$flash["normal"] = "Du har redan taggat #{@tag.name}"
			end
		end
		haml :my_page
	else
		haml :create_user
	end
end
