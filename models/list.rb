class List
  include DataMapper::Resource
  require 'rdiscount'
  

  property :id, Serial, :required => true, :key => true
  property :slug, String, :required => true, :key => true
  
  property :title, String, :required => true
  property :description, Text
  property :access_type, Integer, :default => 1 #Public access
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has n, :items, "ListItem"
  
  def add_if_allowed(params, user)
    return false unless ACCESSCONTROL::ACCESS_TYPES[self.access_type].can_access?(self, user)
    return self.items.create(params)
  end
  
end
