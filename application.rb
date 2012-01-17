require './environment.rb'

helpers do  
  # compose a link tag
  def link_tag(args={})
    $stderr.puts
    "<a href=\"#{args[:to]}\"" + " class=\"#{args[:class]}\" " + ">#{args[:name]}</a>"
  end
  
  # pretty time format
  def pretty_time(t)
    t.strftime("%m/%d/%y")
  end
  
  # returns url for gravatar
  def gravatar(args={})
    email = args[:email]
    size = args[:size] || 100
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=#{size}&d=monsterid"
  end

  def authenticate!
    redirect '/' unless @user
  end
end

before do
  @user = User.get(session[:user_id]) if session[:user_id]
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
  authenticate!
  
  @experiments = Experiment.all
  erb :experiments
end

get '/experiment/new' do
  authenticate!
  erb :experiment_new
end

post '/experiment/new' do
  authenticate!
  
  experiment = Experiment.new
  experiment.name = params[:name]
  experiment.description = params[:description]
  
  experiment.users << @user
  
  if experiment.valid?
    session[:flash] = "Created a new experiment!"
    redirect "/experiment/#{experiment.id}"
  else
    session[:error] = "Something went wrong"
    redirect '/experiment/new'
  end
end

get '/experiment/:id' do
  authenticate!
  
  id = params[:id]
  @experiment = Experiment.get(id)
  
  if !@experiment.nil?
    erb :experiment
  else
    session[:error] = "no such experiment \'#{params[:id]}\'"
    redirect '/experiments'
  end
end

get '/experiment/:id/delete' do
  authenticate!
  
  @experiment = Experiment.get params[:id]
  if @experiment.destroy
    session[:flash] = 'deleted!'
    redirect '/experiments'
  else
    session[:error] = 'something went wrong?!'
  end
end

##
# Users
#
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
  user = User.new
  user.name = params[:name]
  user.password = params[:password]
  user.email = params[:email]
  
  # need validation here
  if user.valid?
    user.save
    session[:user_id] = user.id
    session[:flash] = "Welcome, #{user.name}!"
    redirect '/'
  else
    session[:error] = "Something went wrong :("
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

get '/session/destroy' do
  session.clear
  session[:flash] = "Succesfully logged-out"
  redirect '/'
end

##
# Uploading/Downloading
get '/upload' do
  erb :upload
end

post '/upload' do
  unless params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
    @error = "No file selected"
    return haml(:upload)
  end
  STDERR.puts "Uploading file, original name #{name.inspect}"
  while blk = tmpfile.read(65536)
    # here you would write it to its final location
    STDERR.puts blk.inspect
  end
  "Upload complete"
end

get '/download' do
  if session[:user_id]
    erb :download
  else
    session[:error] = "Please log in"
    redirect '/'
  end
end

# 'currently you can only download from files folder'
# 'But does not restrict browsing files for download'
post '/download' do
  filename=params[:filename]
  if File.exists?("./files/"+filename)
    send_file "./files/#{filename}", :filename => filename, :type => 'Application/octet-stream'
  else
    session[:error] = "File does not exist in files folder"
    redirect '/'
  end
end

