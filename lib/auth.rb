
def authorize
	@user = User.find(cookies[:user_id])
end

def is_admin
	cookies[:admin_password] == $password
end
