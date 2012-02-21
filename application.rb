require './environment.rb'
require './helpers.rb'

Dir['./routes/*'].each { |f| require f }

before do
  @user = User.get(session[:user_id]) if session[:user_id]
end