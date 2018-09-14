# HashPass cracking WebApp & Server for ✨hashcat✨

Background: This project was created because I had an idea how I can really start abusing WIFI while out in the field. Armed with my raspberry pi and Alfa card, I was capturing lots of wifi handshakes and needed a server to offload the cracking to. I also wanted the server to send me an SMS once it finds the password. Hashpass was born! Since then, this project has grown to aim to support all of hashcats features. I don't even use the hashcat command line anymore and if I need to then I'll just add a new feature to HashPass. If you need a feature implemented, please send me a message and I'll do my best. DISCLAIMER: Don't do anything naughty with this. Obey the law!!

See my other project, AgentOrange for using the new PMKID capture methodto to send hashes the API. This new method is insane! 🙀 (Thanks ZerBea https://github.com/ZerBea/hcxtools and the haschat team for discovering this!!). I've put this script on a headless raspberry pi running gpsd and I'm able to send hashes along with GPS coordiantes to my server. Hashpass will start targed attacks on these networks by using some regex pattern matching on the SSID. For example, Netgear routers will get the WoNDeR wordlist, ATT whill get pskracker, fallbacks to something quick like rockyou, etc. Once the password is found I'll get an SMS message with SSID:pass 😏. To paint a picture: I'm driving around with this raspberry pi running and laughing as my phone is blowing up with text messages lol

![screenshot from 2018-08-23 20-20-36](https://user-images.githubusercontent.com/42399304/44563246-35489800-a712-11e8-8a3e-203188858029.png)

Features
======================
- Backend API server for sending hashes and controlling the application remotely. (Ruby/SQLite)
- Custom designed frontend with a l33t hax0r theme similar to a terminal environment. (VueJS)
- Hash queing
- Cracking progress is updated in real time. Hashcat output automatically gets fed into the frontend.
- Database driven. Upload and manage hashes, dictionaries, rules with attack history and pause/resume
- Auth with user account roles and management settings
- Regular security hardning against common attacks such as XSS, SQL injection, click jacking and CSRF
- SMS and Email notifcations
- Maps integration for attaching lat/long to your hashes. Great for WIFI ;)

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
- rename ```sample.env``` to ```.env```. Open .env and configure the options if you want to secure your server or get SMS/Email notifications working. Setup gmail app password [here](https://myaccount.google.com/apppasswords)
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
