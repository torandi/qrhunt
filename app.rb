require 'sinatra/base'
require 'sinatra/cookies'
require 'haml'
require 'active_record'

require_relative 'config.rb'

require_relative 'lib/db.rb'
require_relative 'lib/auth.rb'

get '/' do
	@users = User.all
	haml :index
end

get '/admin' do
	if @is_admin
	haml :admin
end

get '/qr/:code' do 
end
