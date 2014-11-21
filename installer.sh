#!/bin/bash
#A simple install script for an IRC channel & bot

function pause(){
	read -p "$*"
}

function installWillie(){
	echo
	echo '## Installing the Willie!! ##'
	echo
	echo '## Getting pip ##'
	echo
	sudo wget https://bootstrap.pypa.io/get-pip.py -P /tmp/
	sudo python /tmp/get-pip.py
	echo
	echo '## Pip installed! ##'
	echo
	echo '## Installing the Willie bot ##'
	echo
	sudo pip install willie
	echo
	echo '## The Willie has been installed! ##'
	echo
	echo '## Installing extra dependency ##'
	sudo pip install backports.ssl_match_hostname
	echo
	mkdir -p ~/.willie || exit 1
	echo '## Generating configuratoin file ##'
	genCfg
	echo
	echo '## done with config ##'
	echo '## starting willie in the background ##'
	willie -d --quiet
	echo
	echo '## Done ##'
}

function credits(){
	echo
	echo "Script created for CS331 final project at Saginaw Valley State University"
	sleep 5
	echo "For more information about IRCD-HYBRID check out http://www.ircd-hybrid.org/"
	sleep 5
	echo "For more information about Willie, check out https://github.com/embolalia/willie/wiki"
	sleep 5
	echo
	printPi
}

function printPi(){
	echo "
   .~~.   .~~.
  '. \ ' ' / .'
   .~ .~~~..~.
  : .~.'~'.~. :
 ~ (   ) (   ) ~
( : '~'.~.'~' : ) The Raspberry Pi
 ~ .~ (   ) ~. ~  IRC Server
  (  : '~' :  )
   '~ .~~~. ~'
       '~'"
}

function genCfg(){
	myIP="$(ipAddr)"
	echo -e "[core]\nnick = Willie\nhost = $myIP\nuse_ssl = False\nport = 6667\nowner = pi\nchannels = #help,#pi" > ~/.willie/default.cfg
}

function ipAddr(){
	ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
}

echo "## Updating repositories ##"
echo "## Sudo should only ask for your password once ##"
echo
sleep 5
sudo apt-get update
sudo apt-get upgrade
echo
echo "## Finished updating ##"
echo
echo "## Now installing irc server ##"
echo
sudo aptitude install ircd-hybrid
echo
echo "## IRC server installed! ##"
echo "## You will now generate a random password to be used for the admin ##"
echo
sleep 10
mkpasswd
echo "## Copy it in your clipboard or write it down now ##"
echo "## You will need it for the next step ##"
echo
sleep 10
echo "## Getting new config file ##"
sudo wget https://gist.githubusercontent.com/tizz98/97e02bdbdabeacc638d2/raw/4780390bcc8859fe9d42e7c5093e526c71980b28/ircd.motd -P /tmp/
sudo chmod o+rwx /etc/ircd-hybrid/
sudo mv /tmp/ircd.conf /etc/ircd-hybrid/ircd.conf
sudo wget https://gist.githubusercontent.com/tizz98/97e02bdbdabeacc638d2/raw/5c9a9a2a7b6bfe6a9f8bf01330c183899a6de033/ircd.motd -P /tmp/
sudo mv /tmp/ircd.motd /etc/ircd-hybrid/ircd.motd
echo
echo "## Now the only manual part of this setup ##"
echo "## when the file opens you need to find where it says ##"
echo "              operator {"
echo '## then find where it says password = "v4QsQs2Pc9mb."; and change it to the password you created ##'
echo '## whey you are done, press [ctrl] + [x] then [y] then [enter] ##'
pause 'Press [Enter] key to continue...'
sudo nano /etc/ircd-hybrid/ircd.conf
echo
echo '## restarting IRC server for changes to take effect ##'
sudo /etc/init.d/ircd-hybrid restart
echo
printPi
echo
echo "## Finished installing IRC server! You can access it at the following ip address on port 6667"
echo
ipAddr
echo
read -r -p "Would you like to install a bot that monitors all your IRC channels? [y/N] " response
case $response in
	[yY][eE][sS]|[yY])
		installWillie
		credits
		;;
	*)
		echo
		echo '## DONE ##'
		credits
		exit 1
		;;
esac
