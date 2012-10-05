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
	has_many :tags
	validates_uniqueness_of :name

	def score
		tags.reduce do |sum, tag|
			sum += tag.points
		end
	end

	def add_tag(tag) 
		if !tags.find_by_code(tag.code)
			tags << tag
			true
		else
			false
		end
	end
end
