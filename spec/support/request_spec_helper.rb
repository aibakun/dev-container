module RequestSpecHelper
  def login(user, password)
    process :post, login_path, params: { email: user.email, password: password }
  end
end
