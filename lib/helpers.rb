# helpers.rb

helpers do

  def generate_token(user)
    # needs to be some random value:
    token_value = user.uid.to_s + '-12345678'
    token = Token.new({:value => token_value, :uid => user.uid.to_s, :app => 'app.platform', :created_at => DateTime.now})
    token.save
    token_value
  end

end

