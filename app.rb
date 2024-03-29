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

before do
	$flash = Hash.new 
end

get '/' do
	@users = User.ranking
	haml :index
end

get '/live' do
	@users = User.ranking
	@live = true
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

get '/login/:id' do |id|
	redirect to '/admin' unless is_admin
	@user = User.find_by_id(id)
	cookies[:user_id] = id
	cookies[:user_key] = @user.key
	redirect to '/u'
end

get '/logout' do
	cookies[:admin_password] = ""
	redirect to '/'
end

get '/ulogout' do
	redirect to '/' unless is_admin # Only admins may logout normal users
	cookies[:user_id] = nil
	redirect to '/admin'
end

post '/add_tag' do
	redirect to "/admin" unless is_admin

	@tag = Tag::new(params)
	@tag.generate_code
	if @tag.save
		$flash["success"] = "Skapade tag"
		haml :admin
	else
		$flash["error"] = "Failed to save tag, #{@tag.errors.inspect}"
		haml :admin
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

post '/delete_user' do
	redirect to '/' unless is_admin
	@user = User.find_by_id(params[:id])
	if @user
		if @user.delete
			$flash['success'] = "Användaren raderades"
		else
			$flash["error"] = "Kunde inte radera användaren: #{@user.errors}"
		end
	else
		$flash["error"] = "Användaren hittades inte"
	end
	haml :admin
end

post '/create_user' do
	@code = params[:code]
	if User.find_by_name(params[:name])
		$flash["error"] = "Namnet är upptaget, kom på nått nytt för fan!"
		haml :create_user
	else
		@user = User.new(:name=>params[:name])
		@user.generate_key
		@user.save
		cookies[:user_id] = @user.id
		cookies[:user_key] = @user.key
		if @code
			redirect to("/qr/#{@code}")
		else
			redirect to "/u"
		end
	end
end

get '/qr/:code' do
	@code = params[:code]
	@tag = Tag.find_by_code(@code)
	$flash["error"] = "Ogiltlig kod." unless @tag
	if authorize
		if @tag
			if @user.add_tag(@tag)
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
