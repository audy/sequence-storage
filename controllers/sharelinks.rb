##
# Temporary Share Links (JSON)
#

get '/sharelink/?' do
  $stderr.puts params.inspect
  object = params[:for]
  id = params[:id]
  
  ob = 
    case object
    when 'experiment'
      Experiment.get id
    when 'dataset'
      Dataset.get id
    else
      return { :status => 'error', :message => 'invalid type' }.to_json
    end
  
  s = Sharelink.new object.to_sym => ob
  s.expire_at = Time.now + (2*7*60*60) # 2 weeks
  begin
    s.save
  rescue
    return { :status => 'error', :messages => 'could not save'}.to_json
  end
  
  {
    :status => 'okay',
    :value => s.value,
    :expire_at => s.expire_at
  }.to_json
end

get '/getrandomstring/?' do
  
  $stderr.puts params.inspect

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
    s.expire_at = Time.now + (2*7*24*60*60)      # To get 2 weeks = 2 * days*hours*minutes*seconds
  if s.valid?                                  # Return JSON with response if valid
    s.save
    { 
      :value => s.value,
      :status => 'okay',
      :expire_at => s.expire_at
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
  if @sharelink.expire_at < DateTime.now
    @sharelink.destroy
    session.clear
    session[:error] = 'The link has expired'
    redirect '/'
  end
  if @sharelink.experiment
    @experiment = @sharelink.experiment
    session[:temp_user_type] = "experiment"
    session[:temp_user] = @experiment.id
    erb :experiment
  elsif @sharelink.dataset
    @file = @sharelink.dataset
    session[:temp_user_type] = "dataset"
    session[:temp_user]= @file.id
    erb :file 
  else
    redirect "/"
  end
end