# helpers.rb
require 'digest/sha2'

helpers do

  def generate_token(user)
    token_value = Digest::SHA512.hexdigest(user.uid.to_s + '12345678' + DateTime.now.to_s)
    token = Token.new({:value => token_value, :uid => user.uid.to_s, :app => 'app.platform', :created_at => DateTime.now})
    token.save
    token_value
  end

end

