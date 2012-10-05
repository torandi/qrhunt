require_relative 'config.rb'

ActiveRecord::Base.establish_connection(@db_config)

@db_config = nil

# Models

class Code < ActiveRecord::Base 
	
end

class User < ActiveRecord::Base

end
