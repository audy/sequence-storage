##
# Home
#
get '/' do
  if @user
    @experiments = Experiment.all.last(10).reverse
    @stats = {
      :total_file_size => Dataset.map(&:size).compact.inject(0, :+),
    }
  end
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
