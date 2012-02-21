##
# Home
#
get '/' do
  erb :home
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