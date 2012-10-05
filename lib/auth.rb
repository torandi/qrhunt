
def authorize
	if cookies[:user_id] && cookies[:user_key]
		@user = User.find_by_id(cookies[:user_id])
		@user = nil if @user && cookies[:user_key] != @user.key
		return @user
	else
		return nil
	end
end

def is_admin
	cookies[:admin_password] == $password
end
