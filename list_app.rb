require 'bundler/setup'

require 'sinatra'
require 'haml'

require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-observer'


APP_DIR = File.expand_path(File.dirname(__FILE__))
MODELS_DIR = File.join(APP_DIR, 'models')
PUBLIC_DIR = File.join(APP_DIR, 'public')

require File.join(MODELS_DIR, 'access_control.rb')
require File.join(MODELS_DIR, 'list.rb')
require File.join(MODELS_DIR, 'list_item.rb')

#Setup
set :public, PUBLIC_DIR
set :sessions

configure :test do
  DataMapper.setup(:default, "sqlite3::memory")
  DataMapper.auto_upgrade!
end

configure do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/list.db.sqlite3")
  DataMapper.auto_upgrade!
  HOST = "http://localhost:4567"
end

before do
  @flash = {:notice => nil, :error => nil}
end

#General routes
get '/' do
  haml :"welcome"
end

get '/:slug' do
  @list = List.get(:slug => params[:slug])
  redirect '/' if @list.nil?
  haml :"lists/show"
end

post '/:slug/add' do
  @list = List.get(:slug => params[:slug])
  @list.add_if_allowed(params[:list_item])
  redirect "/#{@list.slug}"
end

get '/popular' do
  @lists = List.popular
  haml :"lists/index"
end

get '/all' do
  @lists = List.all
  haml :"lists/index"
end
