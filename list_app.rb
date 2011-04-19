require 'bundler/setup'

require 'sinatra'
require 'haml'
require 'omniauth'

require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-observer'


APP_DIR = File.expand_path(File.dirname(__FILE__))
MODELS_DIR = File.join(APP_DIR, 'models')
PUBLIC_DIR = File.join(APP_DIR, 'public')

Dir[MODELS_DIR + "/*.rb"].each { |file| require file }

#Setup
set :public, PUBLIC_DIR
set :sessions

use OmniAuth::Builder do
  provider :twitter, Auth::TWITTER[:key], Auth::TWITTER[:secret]
  provider :facebook, Auth::FACEBOOK[:key], Auth::FACEBOOK[:secret]
end

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
  @current_user = User.get(session[:user_id])
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


# Omniauth Routes
post '/auth/:name/callback' do
  auth = request.env['omniauth.auth']
  authentication = Authentication.first(:provider => auth['provider'], :uid => auth['uid'])
    if authentication
      session[:user_id] = authentication.user.id
    elsif current_user
      current_user.authentications.build(
        :provider => auth['provider'],
        :uid => auth['uid']
      )
    else
      session[:user_id] = User.create_with_omniauth(auth).id
    end
end

private

def current_user
  @current_user
end

def require_user(redirect_to)
  redirect redirect_to unless current_user
end

def require_no_user(redirect_to)
  redirect redirect_to if current_user
end
  
