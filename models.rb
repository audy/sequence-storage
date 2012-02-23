# The Experiment Model
#
class Experiment
  include DataMapper::Resource
  include DataMapper::Validate
  
  property :id,          Serial
  property :created_at,  DateTime
  property :update_at,   DateTime
  
  property :name,        String
  property :description, Text
  
  has n, :sharelinks
  
  has n, :datasets
  has n, :users, :through => Resource
  
  validates_presence_of :name
  
  # Generates a link to this object
  def to_url
    "/experiment/#{self.id}"
  end
end

# The User Model
# 
class User
  include DataMapper::Resource
  include DataMapper::Validate
  include BCrypt
  
  attr_accessor :password
    
  property :created_at, DateTime
  
  property :id,    Serial
  property :email, String
  property :name,  String
  property :crypted_password, String, :length => 70
  
  has n, :experiments, :through => Resource
  has n, :datasets
  
  validates_uniqueness_of    :email,    :case_sensitive => false
  validates_format_of        :email,    :with => :email_address
  validates_presence_of      :password, :if => :password_required
  validates_presence_of      :name
  
  # Generates a link to this object
  def to_url
    "/user/#{self.id}"
  end
  
  ##
  # This method is for authentication purpose
  #
  def self.authenticate(email, password)
    account = first(:conditions => { :email => email })
    account && account.has_password?(password) ? account : nil
  end
  
  def has_password?(password)
    Password.new(crypted_password) == password
  end
  
  # Callbacks
  before :save, :encrypt_password
  
  private
  
    def password_required
      !(crypted_password.nil? || password.nil?)
    end
  
    def encrypt_password
      self.crypted_password = Password.create(password)
    end
end


# The File Model
# 
class Dataset
  include DataMapper::Resource
  include DataMapper::Validate
  
  property :id,         Serial
  property :size,       Integer
  property :created_at, DateTime
  property :path,       String # /path/to/thefile.ext
  property :mdsum,      String
  
  has n, :sharelinks
  
  belongs_to :user
  belongs_to :experiment

  # Generates a link to this object
  def to_url
    "/file/#{self.id}"
  end

  def name
    File.basename(self.path)
  end
end


# Sharelink Model
#

class Sharelink
  include DataMapper::Resource
  include DataMapper::Validate

  property :id,         Serial
  property :value,      String, :length => 54, :default => Proc.new { SecureRandom.urlsafe_base64(40) }
  property :created_at, DateTime
  property :expire_at,  DateTime
  
  belongs_to :dataset, :required => false
  belongs_to :experiment, :required => false
  
  validates_with_method :check_for_dataset_or_experiment

  def check_for_dataset_or_experiment
    if (self.dataset || self.experiment) && !(self.dataset && self.experiment)
      return true
    else
      return [ false, "Must have either a Dataset or an Experiment."]
    end
  end
end