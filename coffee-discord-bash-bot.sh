#!/bin/bash

server="$1"
CONTAINER_MIN_AGE="200" #Minimum age of container before allowing reboot
prefix="" #Determines which box to ssh into

if [ -z "$1" ]; then echo "Missing parameter"; exit 1; fi

#check that variable is a docker container
[[ $(docker ps --filter "name=^/$server$" --format '{{.Names}}') == $server ]] && echo "$server exists" || { echo "$server doesn't exist"; exit 1; }
#check that container is plex
[[ $(docker inspect "$server" | grep linuxserver/plex) ]] && echo "is plex" || { echo "not a plex container"; exit 1; }

#set port and URL
port=$(docker inspect "$server" | jq -r ' .[].HostConfig.PortBindings."32400/tcp" | .[].HostPort')
URL="http://127.0.0.1:$port/identity"

STATUS_CODE=$(curl -m 20 -s -o /dev/null -w "%{http_code}\n" "${URL}")

#check if plex container alive for less than 60 seconds
CREATED_TIMESTAMP=$(date --date=$(${prefix} /usr/bin/docker inspect --format='{{.State.StartedAt}}' "$server") +%s)
CURRENT_TIMESTAMP=$(date +%s)
CREATED_TIME=$(($CURRENT_TIMESTAMP-$CREATED_TIMESTAMP))
	
if test $STATUS_CODE -ne 200; then
    if [ -z "$2" ] && [ $CREATED_TIME -gt $CONTAINER_MIN_AGE ]; then 
		${prefix} /usr/bin/docker restart $server
		printf "Restarted $server server at\t $(/bin/date)\n" >> /opt/logs/plex_restart.log
    fi
    printf "%10s = Up %5d seconds. %10s server was down\n" $server $CREATED_TIME $1
	exit 0
else
    printf "%10s = Up %5d seconds. %10s server is fine\n" $server $CREATED_TIME $1
    exit 1
fi
