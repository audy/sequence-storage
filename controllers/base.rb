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

  query = "%#{params[:q].strip}%"

  @results = Set.new
  # Query Users
  @results.merge(
    User.all(:name.like => query) |
    User.all(:email.like => query)
  )

  # Query Experiments
  @results.merge(
    Experiment.all(:name.like => query) |
    Experiment.all(:description.like => query)
  )

  # Query Datasets
  @results.merge Dataset.all(:path.like => query)

  erb :search
end