#!/usr/bin/env bash

#This script will periodically check your IP address and publish it to a git page of your choosing.
#This script should work on GNU/Linux, BSD, and Mac OS X machines.

################################
# User configuration section
################################

IS_NAT="${1:-0}"
WAN_IP_RESOLVER=ifconfig.me
# WAN_IP_RESOLVER=ifconfig.me
# WAN_IP_RESOLVER=icanhazip.com
# WAN_IP_RESOLVER=ident.me
# WAN_IP_RESOLVER=ipecho.net/plain
# WAN_IP_RESOLVER=whatismyip.akamai.com
# WAN_IP_RESOLVER=tnx.nl/ip
# WAN_IP_RESOLVER=myip.dnsomatic.com
# WAN_IP_RESOLVER=ip.appspot.com

################################
# End user configuration section
################################

#check for existence of IP output file.
if [ ! -f ~/ipup2d8/ip ]; then
	echo
else
	touch ~/ipup2d8/ip
fi

mkdir ~/ipup2d8/currentip
#check for existence of file containing current or last known IP.
if [ ! -f ~/ipup2d8/currentip/currentip ]; then
	echo
else
	touch ~/ipup2d8/currentip/currentip
	touch ~/ipup2d8/currentip/currentip/README.md
	git remote add origin https://github.com/teslasmoustache/currentip.git #CHANGE THIS TO YOUR OWN GIT REPO
	git push -u origin master
fi

if [ "$IS_NAT" -eq 0 ] ; then

	#Be sure to change the name of the network interface to the one that
	#YOU are using. It's usually wlan0 or eth0. Use ifconfig to find out.
	ip addr show wlp2s0 > ~/ipup2d8/ip

else

	curl "$WAN_IP_RESOLVER" > ~/ipup2d8/ip
	
fi

#This line takes the lines containing your IP address from the IP #file that was just created and prints it to another file called #'currentip'.
grep "inet" ~/ipup2d8/ip > ~/ipup2d8/currentip/currentip

#The next step is to upload the currentip file to a Git repository. #You need to CREATE a Git repository on some public site. 
#I'm using Github.
