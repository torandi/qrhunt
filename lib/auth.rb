
def authorize
	if cookies[:user_id]
		@user = User.find_by_id(cookies[:user_id])
		return @user
	else
		return nil
	end
end

def is_admin
	cookies[:admin_password] == $password
end
