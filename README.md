# Hashpass Hashcracking Web Application 

## Build Setup
install hashcat: https://hashcat.net/hashcat/
rename sample.env to .env and configure options
```
bundle install
yarn
```

## Server
```
yarn run build
APP_ENV=production bundle exec rackup -p 80 --host 0.0.0.0
# visit localhost in browser
```
