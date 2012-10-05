require 'digest/sha1'

ActiveRecord::Base.establish_connection(@db_config)

@db_config = nil

# Models

class Tag < ActiveRecord::Base 
	validates_uniqueness_of :name
	validates_uniqueness_of :code


	def generate_code
		self.code = Digest::SHA1.hexdigest "#{name}#{Time.now}" 
	end
end

class User < ActiveRecord::Base
	has_many :code
	validates_uniqueness_of :name

	def score
		codes.reduce do |sum, code|
			sum += code.points
		end
	end
end
