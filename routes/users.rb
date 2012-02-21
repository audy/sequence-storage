get '/users?/?' do
  authenticate!
  
  @users = User.all
  erb :users
end

get '/user/new' do
  # TODO implement some kind of invitation code thing
  erb :user_new
end

get '/user/:id' do
  authenticate!
  @view_user = User.get(params[:id])
  erb :user
end

post '/user/new' do  
  begin
    user = User.new
    user.name = params[:name]
    user.password = params[:password]
    user.email = params[:email]
    user.save
    
    session[:user_id] = user.id
    session[:flash] = "Welcome, #{user.name}!"
    
    redirect '/'
  rescue
    session[:error] = "Please check if the fields are correct."
    redirect '/user/new'
  end
end

##
# Sessions
#
get '/session/new' do
  erb :session_new
end

post '/session/new' do
  begin
    email, password = params[:email], params[:password]
    user = User.authenticate(email, password)
    his = %w[Yo Howdy Hey Hi Hello]
    
    session[:user_id] = user.id
    session[:flash] = "#{his.sample}, #{user.name}!"
    redirect '/'
  rescue
    session[:error] = "Invalid"
    redirect '/session/new'
  end
end

get '/session/destroy' do
  byes = %w[Bye Cya Later Ciao Sayonara]
  session.clear
  session[:flash] = "#{byes.sample}, #{@user.name}!"
  redirect '/'
end