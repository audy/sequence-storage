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