class ListItem
  include DataMapper::Resource
  
  #TODO replace with 'Display' polymorphic - i.e. TextDisplay, ImageDisplay
  property :id, Serial
  property :content, Text
  
  belongs_to :list
  
end
