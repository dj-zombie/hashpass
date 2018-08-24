require './app'

use Rack::Session::Cookie, :secret => ENV['SECRET']
use Rack::Attack
use Rack::Protection
use Rack::Protection::CookieTossing 
use Rack::Protection::EscapedParams
use Rack::Protection::RemoteReferrer
use Rack::Protection::StrictTransport
set :environment, :production if ENV['APP_ENV'] == 'production'


run Rack::URLMap.new({
  '/' => Public,
  '/api' => Api
})
