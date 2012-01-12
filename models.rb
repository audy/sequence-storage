

# The Experiment Model
#
class Experiment
  include DataMapper::Resource
  
  property :id,          Serial
  property :created_at,  DateTime
  
  property :name,        String
  property :description, Text
  
  validates_presence_of :name
  
end

# The User Model
# 
class User
end