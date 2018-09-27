# Hashpass cracking WebApp & Server for ✨hashcat✨

Complete wrapper that offers every feature of hashcat in an easy to use UI. From now on, there is no better way to interface with hashcat than Hashpass!

Dashboard:
![screenshot from 2018-09-27 15-42-36](https://user-images.githubusercontent.com/42399304/46179460-3d937600-c270-11e8-98b1-b94d2c04ffe9.png)
![screenshot from 2018-09-27 15-45-11](https://user-images.githubusercontent.com/42399304/46179464-3f5d3980-c270-11e8-8bae-f1257d4d9b89.png)
![screenshot from 2018-09-27 15-48-05](https://user-images.githubusercontent.com/42399304/46179488-59971780-c270-11e8-82b4-87bba089b4f2.png)
![screenshot from 2018-09-27 15-48-43](https://user-images.githubusercontent.com/42399304/46179492-5b60db00-c270-11e8-9210-1b99b0fb25ba.png)
![screenshot from 2018-09-27 15-49-14](https://user-images.githubusercontent.com/42399304/46179495-5d2a9e80-c270-11e8-8365-8fbe1ae7f428.png)
![screenshot from 2018-09-27 15-49-29](https://user-images.githubusercontent.com/42399304/46179505-6451ac80-c270-11e8-8774-947e22901ffe.png)
![screenshot from 2018-09-27 15-50-57](https://user-images.githubusercontent.com/42399304/46179507-661b7000-c270-11e8-827d-b006fe46a9bc.png)
![screenshot from 2018-09-27 15-54-26](https://user-images.githubusercontent.com/42399304/46179508-674c9d00-c270-11e8-8e03-524409d87aa7.png)
![screenshot from 2018-09-27 15-55-02](https://user-images.githubusercontent.com/42399304/46179516-6ca9e780-c270-11e8-805e-b24609b5684f.png)
![screenshot from 2018-09-27 16-10-13](https://user-images.githubusercontent.com/42399304/46179518-6ddb1480-c270-11e8-931b-4ba9c65b32b6.png)
![screenshot from 2018-09-27 16-12-01](https://user-images.githubusercontent.com/42399304/46179519-6f0c4180-c270-11e8-929e-6f3652e92d06.png)


Features
======================
- Backend API server for sending hashes and controlling the application remotely. (Ruby/SQLite)
- Custom designed frontend similar to a terminal environment. (VueJS)
- Hash queing
- Cracking progress is updated in real time. Hashcat output automatically gets fed into the frontend. Websockets implementation in next release!
- Database driven. Upload and manage hashes, dictionaries, rules with attack history and pause/resume
- Auth with user account roles and management settings
- Regular security hardning against common attacks such as XSS, SQL injection, click jacking and CSRF
- SMS and Email notifcations
- Maps integration for attaching lat/long to your hashes. Great for WIFI ;) New method of wardriving but also cracking the hash in real time! Anyone else doing this? 
- Agents, two kinds: RottenPi & Hive. RottenPi is another project of mine that allows me to capture hashes via Responder/PMKID/Handshakes etc and queue them up for cracking with the hashpass API. Hive is my project for distributed password cracking which will allow a network of computers running hashcat to recieve a chunk of the keyspace.

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
.........

### All platforms
- ```$ git pull git@github.com:dj-zombie/hashpass.git```
- ```$ cd hashcat```
- ```$ gem install bunlder && bundle install```
- ```$ yarn install```
- rename ```sample.env``` to ```.env```. Open .env and configure the options if you want to secure your server or get SMS/Email notifications working. Setup gmail app password [here](https://myaccount.google.com/apppasswords)
- run the server ```$ ./server.sh```
- visit ```localhost:9292``` in your browser
- login as hashpass:hashpass
- for security reasons, create a new admin account & delete the hashpass user
- add a dictionary in the settings menu. [Download dics](https://github.com/danielmiessler/SecLists)
- add a hash in the hashes page by clicking ADD. [Hash Generator](https://www.onlinehashcrack.com/hash-generator.php)
- select it by clicking the checkbox and click QUEUE
- choose your dictionary and click SUBMIT
- click CRACK
- PROFIT! 💰
