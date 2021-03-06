get '/file/new/?' do
  authenticate!
  @experiment = Experiment.get(params[:experiment])
  erb :file_new
end

post '/file/new/?' do
  authenticate!
  
  @experiment = Experiment.get(params[:experiment])

  if @experiment.nil?
    session[:error] = "Experiment not found!"
    redirect "/experiments"
  end

  dataset = Dataset.new

  dataset.path       = "#{params[:name]}"
  dataset.size       = 100
  dataset.mdsum      = "ok"
  dataset.last_modified = DateTime.now
  dataset.experiment = @experiment
  dataset.user       = @user

  dataset.save
  
  session[:flash] = "File successfully added to #{@experiment.name}"
  redirect "/experiment/#{@experiment.id}"
end

put '/file/:id?' do
  authenticate!
  $stderr.puts "HELLLOOOOOO"
  @file = Datset.get params[:file_id]
  @file.inspect
  session[:flash] = "Updated File!"
  redirect "/file/#{@file.id}"
end

get '/file/:id' do
  authenticate!

  @file = Dataset.get(params[:id])
  @experiment = @file.experiment
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

##
# File downloading
#
get '/f/:id' do

  dataset = Dataset.get params[:id]
  unless params[:share]
    authenticate!
  else
    sl = Sharelink.get params[:share]
    
    correct_dataset = (sl.dataset_id && (sl.dataset_id != dataset.id))
    
    correct_experiment = (sl.experiment_id && (Experiment.get(sl.experiment_id).datasets.include? dataset))
    
    redirect '/' unless correct_dataset || correct_experiment

  end

  s3_connect
  
  s3_url = 
    begin
      AWS::S3::S3Object.url_for(dataset.path, BUCKET_NAME, :use_ssl => true)
    rescue
      session[:error] = "There was a problem with S3."
      redirect '/'
    end
  redirect s3_url
end