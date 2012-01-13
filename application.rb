require './environment.rb'

helpers do
  def link_tag(args={})
    "<a href=\"#{args[:to]}\">#{args[:name]}</a>"
  end
end

##
# Home
#
get '/' do
  erb :home
end

##
# List all experiments
#
get '/experiments?/?' do
  @experiments = Experiment.all
  erb :experiments
end

# Get a specific experiment
#
get '/experiment/:id' do
  id = params[:id]
  @experiment = Experiment.get(id)
  erb :experiment
end

##
# Users
#
get '/users?/?' do
  @users = User.all
  erb :users
end

get '/user/:id' do
  @user = User.get(params[:id])
  erb :user
end

##
# Sessions
#

get '/session/new' do
  erb :session_new
end

post '/session/new' do
  email, password = params[:email], params[:password]
  user = User.authenticate(email, password)
  
  if user
    session[:user_id] = user.id
    session[:flash] = "Hello, #{user.name}!"
    redirect '/'
  else
    session[:error] = "Invalid"
    redirect '/session/new'
  end
  
end