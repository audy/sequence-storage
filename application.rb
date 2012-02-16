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

    if !@user 
     redirect '/'
    end
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
  begin
    experiment = Experiment.create(params)
    experiment.users << @user
  
    experiment.save
    session[:flash] = "Created a new experiment!"
    redirect "/experiment/#{experiment.id}"
  rescue
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
  
  session[:error]="delete has been disabled"
  redirect '/experiments'
  #@experiment = Experiment.get params[:id]
  #if @experiment.destroy
  #  session[:flash] = 'deleted!'
  #  redirect '/experiments'
  #else
  #  session[:error] = 'something went wrong?!'
  #end
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
  begin
    experiment = Experiment.get(params[:id])
    experiment.update(:name => params[:name], :description => params[:description], :update_at => Time.now)
    
    session[:flash] = "Experiment updated!"
    redirect "/experiment/#{experiment.id}"
  rescue
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

get '/file/:id' do
  #authenticate!
  if session[:user_id]
       "ok"
  elsif session[:temp_user]
    temp_user = session[:temp_user]
  else
     redirect '/'
  end
  
  @file = Dataset.get(params[:id])
    
  if @file.nil?
    session[:error] = "no such file \'#{params[:id]}\'"
    redirect '/experiments'
  else
    erb :file
  end
end

post '/file/edit' do
  authenticate!
  begin 
    file = Dataset.get(params[:file_id])
 
    file.update(:name => params[:name]) 
    redirect "/experiment/#{file.experiment.id}"
  rescue
    session[:error] = "Update not succesful!"
    redirect '/experiments'
  end
end

get '/file/:id/edit' do
  authenticate!
  
  @file = Dataset.get params[:id]
  
  if @file.experiment.users.first(:id => session[:user_id]).nil?
    session[:error] = "You are not a owner, you can not modify"
    redirect '/'
  elsif @file.nil?
    session[:error] = "no such file \'#{params[:id]}\'"
    redirect '/experiments'
  end
  
  erb :file_edit
end

get '/file/:id/delete' do
  authenticate!
  
  @file = Dataset.get params[:id]
  
  if @file.nil?
    session[:error] = 'Dataset file not found!'
    redirect '/experiments'
  end 
  
  if @file.experiment.users.first(:id => @user.id).nil?
     session[:error] = "You cannot delete this file because you are not a owner"
     redirect '/experiments'
  end

  begin
    experiment_id = @file.experiment.id
    session[:error] = 'Delete has been disabled'  

    #@file.destroy
    #session[:flash] = 'deleted!'
    redirect "/experiment/#{experiment_id}"
  rescue
    session[:error] = 'something went wrong?!'
  end
end

get '/experiment/:id/add_file' do
  authenticate!
  
  @experiment = Experiment.get(params[:id])
  
  if @experiment.users.first(:id => session[:user_id]).nil?
    session[:error] = "You are not a owner, you can not modify"
    redirect '/'
  end
  
  if @experiment.nil?
    session[:error] = "no such experiment \'#{params[:id]}\'"
    redirect '/experiments'
  else
    erb :experiment_add_file
  end
end

post '/experiment/add_file' do  
  authenticate!
  begin
    experiment = Experiment.get(params[:id])
  
    if experiment.nil?
      session[:error] = "Cannot find experiment"
      redirect "/experiments"
    end
  
    file = Dataset.new
    file.size = 100
    file.path = "/files/"+params[:name]
    file.mdsum = "ok"
    file.experiment = Experiment.get(params[:id])
    file.user = User.get(session[:user_id])

    file.save
    redirect "/experiment/#{params[:id]}" 
  rescue
    session[:error] = "Something went wrong :("
    redirect "/experiment/#{experiment.id}" 
  end
end

#
# File downloading
#

get '/f/:id' do
  authenticate!
  dataset = Dataset.get params[:id]
  full_path = File.join(FILES_ROUTE, dataset.path)
  send_file full_path, :filename => dataset.name, :type => 'Application/octet-stream'
end

#
# Temporary Share Links
#

# THIS IS A JSON-ONLY ROUTE
get '/getrandomstring/:object/:id' do
  authenticate!
  
  # Get type of object sharelink is needed for, and its id
  object = params[:object]
  id = params[:id]
  
  # Attempt to find object in Database
  ob =
    case object
    when 'experiment'
      Experiment.get id
    when 'dataset'
      Dataset.get id
    else
      return { status: 'error' }.to_json
    end
  
  # Complain if object doesn't exist
  # ob.id rescue return { status: 'error' }.to_json
  
  # Create a new sharelink
  s = Sharelink.new(object.to_sym => ob)

  if s.valid? # Return JSON with response if valid
    s.save
    { 
      :value => s.value,
      :status => 'okay',
    }.to_json
  else # Otherwise, Crap
    return { status: 'error' }.to_json
  end
end

get '/path/:long_string' do
  @sharelink = Sharelink.first(:value => params[:long_string])
  
  if @sharelink.nil?
    session[:error] = "No such Experiment"
    redirect "/"
  end
  if @sharelink.experiment
    @experiment = @sharelink.experiment
    session[:temp_user] = @experiment.id
    erb :experiment
  elsif @sharelink.dataset
    @file = @sharelink.dataset
    session[:temp_user]= @file.id
    erb :file 
  else
    "eoore"
  end
end 