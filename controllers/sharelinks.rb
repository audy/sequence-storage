##
# Temporary Share Links (JSON)
#

get '/share/new?' do
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

get '/share/:long_string' do
  @sharelink = Sharelink.first(:value => params[:long_string])
  
  if @sharelink.nil?
    session[:error] = "Invalid Link"
    redirect "/"
  end
  if @sharelink.expire_at < DateTime.now
    @sharelink.destroy
    session.clear
    session[:error] = 'The link has expired'
    redirect '/'
  end

  session[:flash] = "<strong>Howdy, stranger!</strong> It looks like someone is sharing sequence data with you. Go ahead and download it."

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