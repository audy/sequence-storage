require './environment.rb'

helpers do  
  # compose a link tag
  def link_tag(args={})
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
  
  experiment = Experiment.create(params)
  experiment.users << @user
  
  $stderr.puts @user.save
  $stderr.puts @user.errors.inspect
  
  if experiment.save
    session[:flash] = "Created a new experiment!"
    redirect "/experiment/#{experiment.id}"
  else
    session[:error] = "Error?!"
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

get '/experiment/:id/edit' do
  authenticate!
  
  @experiment = Experiment.get params[:id]
  if @experiment.nil?    										#if there is no experiment with that id
    session[:error] = "no such experiment \'#{params[:id]}\'"
    redirect '/experiments'
  else
    if @experiment.users.first(:id => @user.id).nil?			# if the user is not the owner
      session[:error] = "You cannot edit this experiment because you are not a owner"
      redirect '/experiments'
    else
      erb :experiment_edit
    end
  end
end

post '/experiment/edit' do
  authenticate!
  
  experiment = Experiment.get(params[:id])
  
  if experiment.update(:name => params[:name], :description => params[:description], :update_at => Time.now)
    session[:flash] = "Experiment updated!"
    redirect "/experiment/#{experiment.id}"
  else
    session[:error] = "Update Error?! Please check fields again"
    redirect '/experiments'
  end
end

get '/experiment/:id/add_owner' do
  authenticate!
  
  @experiment = Experiment.get params[:id]
  if @experiment.nil?    										#if there is no experiment with that id
    session[:error] = "no such experiment \'#{params[:id]}\'"
    redirect '/experiments'
  else
    ## if @experiment.users.include? @user
    if @experiment.users.first(:id => @user.id).nil?
      session[:error] = "You cannot edit this experiment because you are not a owner"
      redirect '/experiments'
    else
      erb :experiment_add_owner
    end
  end
end

post '/experiment/add_owner' do
  authenticate!
  
  new_owner = User.get(params[:new_owner_id])
  experiment = Experiment.get(params[:experiment_id])
  user = User.get(session[:user_id])
  experiment.users << new_owner
  if experiment.save
  
    redirect "/experiment/#{params[:experiment_id]}"
  else
    session[:error] = "Error adding new owner"
    redirect '/experiments'
  end 
end

post '/experiment/remove_owner' do
  authenticate!
  
  owner_id = params[:owner_id]
  owner = User.get(owner_id)
  experiment = Experiment.get(params[:experiment_id])
  
  link = experiment.experiment_users.first(:user => owner)
  
  if link.destroy
    session[:flash]="Owner Removed!"
    redirect "/experiments"
  else
    session[:error] = "Error removing owner?"
    redirect '/experiments'
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
  his = %w[Yo Howdy Hey Hi Hello]
  if user
    session[:user_id] = user.id
    session[:flash] = "#{his.sample}, #{user.name}!"
    redirect '/'
  else
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

##
# Searching
#
get '/search/?' do
  authenticate!
  $stderr.puts params
  query = "%#{params[:q]}%"
  @results = Set.new
  @results = (User.all(:name.like => query) | User.all(:email.like => query)).to_set + (Experiment.all(:name.like => query) | Experiment.all(:description.like => query)).to_set
  erb :search
end


##
# Uploading/Downloading
get '/upload' do
  authenticate!
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


##
# Files
get '/file/:id' do
  authenticate!
  
  @file = Dataset.get(params[:id])
  
  if @file.nil?
    session[:error] = "no such file \'#{params[:id]}\'"
    redirect '/experiments'
  else
    erb :file
  end
end

post '/file/edit' do
  
  file = Dataset.get(params[:file_id])
 
  if file.nil?
    session[:error] = "Update not succesful!"
    redirect '/experiments'
  else
    file.update(:name => params[:name]) 
    redirect "/experiment/#{file.experiment.id}"    
  end
end

get '/file/:id/edit' do
  authenticate!
  
  @file = Dataset.get params[:id]
  
  if @file.experiment.users.first(:id => session[:user_id]).nil?
    session[:error] = "You are not a owner, you can not modify"
    redirect '/'
  end
   
  if @file.nil?    										#if there is no file with that id
    session[:error] = "no such file \'#{params[:id]}\'"
    redirect '/experiments'
  else
    if @file.experiment.users.first(:id => @user.id).nil?			# if the user is not the owner
      session[:error] = "You cannot edit this file because you are not a owner"
      redirect '/experiments'
    else
      erb :file_edit
    end
  end
end

get '/file/:id/delete' do
  authenticate!
  
  @file = Dataset.get params[:id]
  if @file.nil?
    session[:error] = 'Dataset file not found!'
    redirect '/experiments'
  else  
  
    if @file.experiment.users.first(:id => @user.id).nil?			# if the user is not the owner
      session[:error] = "You cannot delete this file because you are not a owner"
      redirect '/experiments'
    end
    experiment_id = @file.experiment.id
  		
    if @file.destroy
      session[:flash] = 'deleted!'
      redirect '/experiments'
    else
      session[:error] = 'something went wrong?!'
    end
  end
end

get '/experiment/:id/add_file' do
  authenticate!
  
  @experiment = Experiment.get(params[:id])
  
  if @experiment.users.first(:id => session[:user_id]).nil?
    session[:error] = "You are not a owner, you can not modify"
    redirect '/'
  end
  
  if @experiment.nil?    										#if there is no experiment with that id
    session[:error] = "no such experiment \'#{params[:id]}\'"
    redirect '/experiments'
  else
    erb :experiment_add_file
  end
end

post '/experiment/add_file' do  
  experiment = Experiment.get(params[:id])
  
  if experiment.nil?
    session[:error] = "Cannot find experiment"
    redirect "/experiments" 
  end
  
  file = Dataset.new
  file.name = params[:name]
  file.size = 100 
  file.created_at = Time.now
  file.created_by = session[:user_id]
  file.path = "file"
  file.mdsum = "ok"
  file.experiment = Experiment.get(params[:id])

  if file.valid?
    file.save
    redirect "/experiment/#{file.experiment.id}" 
  else
    session[:error] = "Something went wrong :("
    redirect "/experiment/#{experiment.id}" 
  end
  
end