require 'bundler'
require 'sinatra'
require 'webrick/https'
require 'sinatra/json'
require 'sinatra/namespace'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/cookies'
require 'sequel'
require 'sqlite3'
require 'json'
require 'logger'
require 'pry'
require 'mail'
require 'listen'
require 'dotenv/load'
require 'bcrypt'
require 'openssl'
require_relative 'src/server/sinatra_ssl'
require_relative 'src/server/notifications'
require_relative 'src/server/log_parser.rb'
require_relative 'src/server/api.rb'

##
# Connect to SQLite
DB = Sequel.connect('sqlite://hashpass.db')
DB[:active].delete

##
# Hash model
class Hashes < Sequel::Model(DB[:hashes])
end

##
# Attack History model
class History < Sequel::Model(DB[:history])
end

##
# Dictionary model
class Dics < Sequel::Model(DB[:dictionaries])
end

##
# Rules model
class Rules < Sequel::Model(DB[:rules])
end

##
# User model
class User < Sequel::Model
  include BCrypt

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end


##
# app
class App < Sinatra::Base
  register Sinatra::Namespace
  enable :sessions
  helpers Sinatra::Cookies
  api = API.new
  notifications = Notifications.new

  configure :development do
    register Sinatra::Reloader
  end

  not_found do
    api.main_page
  end

  def create_user(user, password)
    @new_user = User.new(email: user, password: password)
    @new_user.save
  end

  get '/' do
    api.login_page
  end

  post '/' do
    @user = User.first(email: params['handle'])
    redirect to '/' if @user.nil? || params['handle'].empty?

    if @user.password == params['password']
      api.main_page
    else
      redirect to '/'
    end
  end

  get '/api/mail' do
    notifications.mail
    json done: true
  end

  get '/api/clean' do
    api.clean
    json done: true
  end

  get '/api/start' do
    pending = DB[:pending].first
    active = DB[:active].first
    if active.nil? && pending
      api.promote
      json pid: api.start(active)
    end
    json pid: api.start(active)
  end

  get '/api/stop/:id' do
    api.stop
    json killed: true
  end

  post '/api/upload' do
    api.upload(params[:files])
    json success: true
  end

  get '/api/status' do
    json api.status
  end

  get '/api/dics' do
    json DB[:dictionaries].all
  end

  post '/api/dic' do
    request.body.rewind
    json api.insert_dic(JSON.parse(request.body.read))
  end

  delete '/api/dic/:id' do
    deleted = Dics.where(id: params['id']).delete
    json deleted: deleted if deleted
  end


  get '/api/rules' do
    json DB[:rules].all
  end

  post '/api/rule' do
    request.body.rewind
    json api.insert_rule(JSON.parse(request.body.read))
  end

  delete '/api/rule/:id' do
    deleted = Rules.where(id: params['id']).delete
    json deleted: deleted if deleted
  end


  get '/api/hashes' do
    json DB[:hashes].reverse_order(:added).all
  end

  get '/api/history' do
    json DB[:history].reverse_order(:started_on).all
  end

  get '/api/history/:id' do
    history = DB[:history].where(hashid: params['id']).reverse_order(:started_on).all
    json history ? history : 'not found'
  end

  delete '/api/hashes/:id' do
    deleted = Hashes.where(id: params['id']).delete
    json deleted: deleted if deleted
  end

  post '/api/hashes/insert' do
    request.body.rewind
    json success: true if api.insert_hash(JSON.parse(request.body.read))
  end

  namespace '/api/running' do
    get do
      status 204 if DB[:active].all.empty?
      json running: DB[:active].all
    end

    get '/pid/:id' do
      json pid: api.pid_active?(params['id'].to_i)
    end

    delete do
      json success: true if DB[:active].delete
    end

    get '/promote' do
      json success: api.promote
    end
  end

  namespace '/api/pending' do
    get do
      json pending: DB[:pending].all
    end

    delete do
      DB[:pending].delete
      json success: true
    end

    post do
      request.body.rewind
      json success: true if api.new(JSON.parse(request.body.read))
    end
  end

  namespace '/api/cracked' do
    get do
      json cracked: DB[:cracked].all
    end

    get '/dir' do
      json cracked: api.cracked
    end

    delete do
      json success: true if DB[:cracked].delete
    end

    get '/insert' do
      json cracked: api.new_cracked
    end

    get '/:id' do
      json cracked: DB[:cracked].where(id: params['id']).first
    end
  end
end
