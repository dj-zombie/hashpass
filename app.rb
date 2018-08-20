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
require 'jwt'
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
# Public (user not authorized)
class Public < Sinatra::Base
  def initialize
    super
  end

  not_found do
    File.read(File.join('public', 'app.html'))
  end

  get '/' do
    File.read(File.join('public', 'app.html'))
  end

  post '/hplogin' do
    request.body.rewind
    params = JSON.parse(request.body.read)
    @user = User.first(email: params['handle'])
    redirect to '/' if @user.nil? || params['handle'].empty?

    if @user.password == params['password']
      hmac_secret = 'my$ecretK3y'
      payload = { 
        exp: Time.now.to_i + 60 * 60,
        iat: Time.now.to_i,
        iss: 'z0mbieee',
        scopes: ['add_money', 'remove_money', 'view_money', 'dashboard'],
        user: {
          username: @user
        }
      }
      token = JWT.encode(payload, hmac_secret, 'HS256')
      decoded_token = JWT.decode token, hmac_secret, true, { algorithm: 'HS256' }

      { token: token(@user.email) }.to_json
    else
      halt 401
    end
  end

  def payload(username)
    {
      exp: Time.now.to_i + 60 * 60,
      iat: Time.now.to_i,
      iss: 'z0mbieee',
      scopes: ['add_money', 'remove_money', 'view_money', 'dashboard'],
      user: {
        username: username
      }
    }
  end

  def token(username)
    JWT.encode(payload(username), 's3cret', 'HS256')
  end
end

##
# JWT
class JwtAuth
  def initialize app
    @app = app
  end

  def call env
    begin
      options = { algorithm: 'HS256', iss: 'z0mbieee' }
      bearer = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
      payload, header = JWT.decode bearer, 's3cret', true, options

      env[:scopes] = payload['scopes']
      env[:user] = payload['user']

      @app.call env
    rescue JWT::DecodeError
      puts "pass a token!"
      [401, { 'Content-Type' => 'text/plain' }, ['A token must be passed.']]
    rescue JWT::ExpiredSignature
      [403, { 'Content-Type' => 'text/plain' }, ['The token has expired.']]
    rescue JWT::InvalidIssuerError
      [403, { 'Content-Type' => 'text/plain' }, ['The token does not have a valid issuer.']]
    rescue JWT::InvalidIatError
      [403, { 'Content-Type' => 'text/plain' }, ['The token does not have a valid "issued at" time.']]
    end
  end

end

##
# API
class Api < Sinatra::Base
  use JwtAuth

  register Sinatra::Namespace
  enable :sessions
  helpers Sinatra::Cookies
  api = API.new
  notifications = Notifications.new

  def initialize
    super
  end

  configure :development do
    register Sinatra::Reloader
  end

  not_found do
    api.main_page
  end

  get '/mail' do
    notifications.mail
    json done: true
  end

  get '/clean' do
    api.clean
    json done: true
  end

  get '/start' do
    pending = DB[:pending].first
    active = DB[:active].first
    if active.nil? && pending
      api.promote
      json pid: api.start(active)
    end
    json pid: api.start(active)
  end

  get '/stop/:id' do
    api.stop
    json killed: true
  end

  post '/upload' do
    api.upload(params[:files])
    json success: true
  end

  get '/status' do
    json api.status
  end

  get '/dics' do
    puts "dics"
    json DB[:dictionaries].reverse_order(:size).all
  end

  post '/dic' do
    request.body.rewind
    json api.insert_dic(JSON.parse(request.body.read))
  end

  delete '/dic/:id' do
    deleted = Dics.where(id: params['id']).delete
    json deleted: deleted if deleted
  end


  get '/rules' do
    json DB[:rules].all
  end

  post '/rule' do
    request.body.rewind
    json api.insert_rule(JSON.parse(request.body.read))
  end

  delete '/rule/:id' do
    deleted = Rules.where(id: params['id']).delete
    json deleted: deleted if deleted
  end


  get '/users' do
    json DB[:users].all
  end

  post '/user' do
    request.body.rewind
    param = JSON.parse(request.body.read)
    @new_user = User.new(email: param['name'], password: param['password'], role: param['role'])
    json @new_user.save
  end

  delete '/user/:id' do
    deleted = User.where(id: params['id']).delete
    json deleted: deleted if deleted
  end


  get '/hashes' do
    json DB[:hashes].reverse_order(:added).all
  end

  get '/history' do
    json DB[:history].reverse_order(:started_on).all
  end

  get '/history/:id' do
    history = DB[:history].where(hashid: params['id']).reverse_order(:started_on).all
    json history ? history : 'not found'
  end

  delete '/hashes/:id' do
    deleted = Hashes.where(id: params['id']).delete
    json deleted: deleted if deleted
  end

  post '/hashes/insert' do
    request.body.rewind
    json success: true if api.insert_hash(JSON.parse(request.body.read))
  end

  namespace '/running' do
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

  namespace '/pending' do
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

  namespace '/cracked' do
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
