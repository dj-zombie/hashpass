require './app'

run Rack::URLMap.new({
  '/' => Public,
  '/api' => Api
})
# run App
