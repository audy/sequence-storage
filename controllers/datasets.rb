get '/file/:id' do
  authenticate!
  @file = Dataset.get(params[:id])

  if session[:user_id]
       "ok"
  elsif (session[:temp_user_type] == "dataset" && session[:temp_user] == params[:id])||(session[:temp_user_type] == "experiment" && session[:temp_user] == @file.experiment.id)
    temp_user = session[:temp_user]
  else
     redirect '/'
  end

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

#
# File downloading
#

get '/f/:id' do
  authenticate!
  dataset = Dataset.get params[:id]
  full_path = File.join(FILES_ROUTE, dataset.path)
  send_file full_path, :filename => dataset.name, :type => 'Application/octet-stream'
end