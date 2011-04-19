class Authentication
  include DataMapper::Resource
  
  property :user_id, Integer, :required => true, :key => true
  property :provider, String, :required => true
  property :uid, String, :required => true, :key => true
  
  belongs_to :user
end
