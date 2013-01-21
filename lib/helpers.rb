# helpers.rb

helpers do

  def generate_token(user)
    user.uid.to_s + '-12345678'
  end

end

