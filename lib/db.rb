require 'digest/sha1'

ActiveRecord::Base.establish_connection(@db_config)

@db_config = nil

# Models

class Tag < ActiveRecord::Base 
	has_and_belongs_to_many :users

	validates_uniqueness_of :name
	validates_uniqueness_of :code


	def generate_code
		self.code = Digest::SHA1.hexdigest "#{name}#{Time.now}" 
	end
end

class User < ActiveRecord::Base
	has_and_belongs_to_many :tags
	validates_uniqueness_of :name

	def position_with_next_and_prev
		# Ah, the fulhack
		users = User.all.sort_by {:score}.reverse
		users.each_with_index do |u, index|
			if u.id == self.id 
				n = nil
				prev = nil
				n = users[index - 1] if index - 1 > -1
				prev = users[index + 1] if index + 1 < users.length
				return index + 1, n, prev
			end
		end
	end

	def position
		pos, n, prev = position_with_next_and_prev
		return pos
	end

	def score
		tags.sum(:points)
	end

	def add_tag(tag) 
		if !tags.find_by_code(tag.code)
			tags << tag
			true
		else
			false
		end
	end

	def generate_key
		self.key = Digest::SHA1.hexdigest "#{Random.rand(1000)}#{name}#{Time.now}" 
	end

	def progress
		100.0 * (score.to_f/Tag.sum(:points).to_f)
	end
end
