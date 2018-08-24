# HashPass cracking WebApp & Server for ✨hashcat✨

![screenshot from 2018-08-23 20-20-36](https://user-images.githubusercontent.com/42399304/44563246-35489800-a712-11e8-8a3e-203188858029.png)

## Build Setup
- install hashcat: https://hashcat.net/hashcat/
- ```gem install bunlder && bundle install```
- ```yarn install```
- rename sample.env to .env and configure the options
- run the server (./server.sh)
- login as hashpass:hashpass
- create a new admin account & delete hashpass user
- add a dictionary in the settings
- add a hash in the hashes page by clicking ADD
- select it by clicking the checkbox and click QUEUE
- choose your dictionary and click SUBMIT
- click CRACK
- profit


## Server
```
yarn build
bundle exec rackup -p80 --host 0.0.0.0
# visit localhost in browser
```
or
```
./server.sh
```
