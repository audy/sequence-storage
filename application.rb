require './environment.rb'

helpers do
  def link_tag(args={})
    $stderr.puts
    "<a href=\"#{args[:to]}\"" + " class=\"#{args[:class]}\" " + ">#{args[:name]}</a>"
  end
  
  def pretty_time(t)
    t.strftime("%m/%d/%y")
  end
end

##
# Home
#
get '/' do
  erb :home
end

##
# Experiments
#
get '/experiments?/?' do
  @experiments = Experiment.all
  erb :experiments
end

get '/experiment/new' do
  erb :experiment_new
end

post '/experiment/new' do
  erb :experiment
end

get '/session/destroy' do
  session[:user_id] = nil
  session[:flash] = 'logged out'
  redirect '/'
end

get '/experiment/:id' do
  id = params[:id]
  @experiment = Experiment.get(id)
  if !@experiment.nil?
    erb :experiment
  else
    session[:error] = "no such experiment \'#{params[:id]}\'"
    redirect '/experiments'
  end
end

##
# Users
#

get '/users?/?' do
  @users = User.all
  erb :users
end

get '/user/new' do
  erb :user_new
end

get '/user/:id' do
  @user = User.get(params[:id])
  erb :user
end

post '/user/new' do
  user = User.new
  user.name = params[:name]
  user.password = params[:password]
  user.email = params[:email]
  
  # need validation here
  user.save
  redirect '/'
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