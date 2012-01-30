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
  
  has n, :datasets
  has n, :users, :through => Resource
  
  validates_presence_of :name
  
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
  
  belongs_to :user
  belongs_to :experiment
  
  validates_presence_of :name
  
  def name
    File.basename(self.path)
  end
end