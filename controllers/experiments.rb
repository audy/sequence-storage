get '/experiments?/?' do  
  authenticate!
  @experiments = Experiment.all
  erb :experiments
end

get '/experiment/new' do
  authenticate!
  erb :experiment_new
end

get '/experiment/:id/?' do
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

post '/experiment/new?' do
  authenticate!

  experiment = Experiment.new

  experiment.name = params[:name]
  experiment.description = params[:description]
  experiment.users << @user

  begin
    experiment.save
  rescue
    session[:error] = "Something went wrong"
    redirect '/experiment/new'
  end
  session[:flash] = "Created a new experiment!"
  redirect "/experiment/#{experiment.id}"
end

post '/experiment/:id/edit' do
  $stderr.puts params.inspect
  @experiment = Experiment.get params[:id]

  if @experiment.users.first(:id => @user.id).nil?
    session[:error] = "Unauthorized"
  end
  
  begin
    @experiment.update(
      :name => params[:name],
      :description => params[:description]
    )
  rescue
    session[:error] = "Something went wrong"
    redirect "/experiment/#{params[:id]}/"
  end
  session[:flash] = "Update Successful"
  redirect "/experiment/#{params[:id]}"
end

get '/experiment/:id/delete' do
  authenticate!

  session[:error] = "Delete has been disabled"
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
  if @experiment.nil?
    session[:error] = "no such experiment \'#{params[:id]}\'"
    redirect '/experiments'
  else
    if @experiment.users.first(:id => @user.id).nil?
      session[:error] = "You cannot edit this experiment because you are not a owner"
      redirect '/experiments'
    else
      erb :experiment_edit
    end
  end
end

get '/experiment/:id/add_owner' do
  authenticate!

  @experiment = Experiment.get params[:id]
  if @experiment.nil?
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
    session[:flash] = "Owner Removed!"
    redirect "/experiments"
  else
    session[:error] = "Error removing owner?"
    redirect '/experiments'
  end
end