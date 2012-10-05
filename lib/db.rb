require_relative 'config.rb'

ActiveRecord::Base.establish_connection(@db_config)

@db_config = nil

# Models

class Code < ActiveRecord::Base 
end

class User < ActiveRecord::Base
	has_many :code

	def score
		codes.reduce do |sum, code|
			sum += code.points
		end
	end
end
