# HashPass cracking WebApp & Server for ✨hashcat✨

![screenshot from 2018-08-23 20-20-36](https://user-images.githubusercontent.com/42399304/44563246-35489800-a712-11e8-8a3e-203188858029.png)

Installation
======================
- First, install hashcat and make sure its accessable in your $PATH: https://hashcat.net/hashcat/

### Linux (debian)
- Install Ruby ```$ apt install ruby-full -y```
- Install yarn ```$ curl -o- -L https://yarnpkg.com/install.sh | bash```

### Mac
- Install NodeJS and Yarn: [Install Guide](https://medium.com/@itsromiljain/the-best-way-to-install-node-js-npm-and-yarn-on-mac-osx-4d8a8544987a)
- Install Ruby ```$ brew install ruby```. For development I recommend [RVM](http://rvm.io/)

### Window$$? (aka Evil Corp)
hahahahahahahahahahahahahahaaaa

### All platforms
- ```$ git pull git@github.com:dj-zombie/hashpass.git```
- ```$ cd hashcat```
- ```$ gem install bunlder && bundle install```
- ```$ yarn install```
- rename ```sample.env``` to ```.env```. Open .env and configure the options if you want to secure your server or get SMS/Email notifications working.
- run the server ```$ ./server.sh```
- visit ```localhost``` in your browser
- login as hashpass:hashpass
- for security reasons, create a new admin account & delete the hashpass user
- add a dictionary in the settings menu. [Download dics](https://github.com/danielmiessler/SecLists)
- add a hash in the hashes page by clicking ADD. [Hash Generator](https://www.onlinehashcrack.com/hash-generator.php)
- select it by clicking the checkbox and click QUEUE
- choose your dictionary and click SUBMIT
- click CRACK
- PROFIT! 💰
