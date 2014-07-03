#! bin/bash

#This script will periodically check your IP address and publish it to a git page of your choosing.
#This script will probably only be compatible with GNU-Linux.

#check for existence of IP output file.
if [ ! -f ~/ipup2d8/ip ]; then
	echo
else
	touch ~/ipup2d8/ip
fi

ip addr show wlp2s0 > ~/ipup2d8/ip
#you will probably need to change the above line. 
#Use ifconfig to find out what the name of the interface is. (e.g. wlan0, or eth0 most commonly)
