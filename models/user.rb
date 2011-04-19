class User
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :required => true
  property :email, String
  
  has n, :authentications
  
  def self.create_from_authentication(auth)
    user = create(:name => auth['user_info']['name'])
    user.authentications.create(
      :provider => auth['provider'],
      :uid => auth['uid']
    )
    return user
  end
end
