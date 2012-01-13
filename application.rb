require './environment.rb'

helpers do
  def link_tag(args={})
    "<a href=\"#{args[:to]}\">#{args[:name]}</a>"
  end
end

# Render home page
get '/' do
  erb :home
end

# List all experiments
#
get '/experiments?/?' do
  @experiments = Experiment.all
  erb :experiments
end

# Get a specific experiment
#
get '/experiment/:id' do
  id = params[:id]
  @experiment = Experiment.get(id)
  erb :experiment
end