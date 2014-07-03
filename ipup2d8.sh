#!/usr/bin/env bash

# Usage: ipup2d8
#        ipup2d8 1
#        ipup2d8 0 en1

# $1: flag (0 or 1) indicating whether we are behind a NAT firewall (1) or not (0)
# $2: name of local network interface to get WAN IP address from. $1 must be 0.

# This script will periodically check your IP address and pass it to each script
# you place in the push-ip.d directory.


################################
# User configuration section
################################

# If you are usually behind a NAT router:
IS_NAT="${1:-1}"
# Otherwise:
#IS_NAT="${1:-0}"
# The name of the local network interface you want to obtain your WAN IP address
# from:
# Be sure to change the name of the network interface to the one that
# YOU are using. It's usually wlan0 or eth0. Use ifconfig to find out.
INTERFACE="${2:-eth0}"
# TODO Randomize
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

IPUP2D8_DIR="${HOME}/.ipup2d8"
IPUP2D8_FILE="${IPUP2D8_DIR}/ip"
TASKS_DIR="${IPUP2D8_DIR}/push-ip.d"

mkdir -p "$IPUP2D8_DIR"
cd "$IPUP2D8_DIR"

touch "$IPUP2D8_FILE"

OLD_IP=`cat "$IPUP2D8_FILE"`

IP="" # store IP

if [ "$IS_NAT" = 0 ]; then
    case `uname` in
        Linux)
            IP=`ifconfig -a "$INTERFACE" | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
            ;;

        FreeBSD|OpenBSD)
            IP=`ifconfig "$INTERFACE" | grep -E 'inet.[0-9]' | grep -v '127.0.0.1' | awk '{ print $2}'`
            ;;

        SunOS)
            IP=`ifconfig -a "$INTERFACE" | grep inet | grep -v '127.0.0.1' | awk '{ print $2} '`
            ;;

        Darwin)
            IP=`ifconfig -u "$INTERFACE" | grep -v 'inet 127.0.0.1' | sed -n 's/\s*inet \(\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}\) .*/\1/p'`
            ;;
    esac
else
    IP=`curl "$WAN_IP_RESOLVER"`
fi

[ "$IP" = "$OLD_IP" ] && exit 0

echo "$IP" > "$IPUP2D8_FILE"

for TASK in `ls "$TASKS_DIR"`; do
    "$TASK" "$IP"
done
