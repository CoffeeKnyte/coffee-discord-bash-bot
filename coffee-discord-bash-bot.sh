#!/bin/bash

server="$1"

case $server in
   "plex") container="plex"; port="32400";;
   "jf") container="jellyfin"; port="8096";;
esac

#port=$(docker inspect "$server" | jq -r ' .[].HostConfig.PortBindings[]' | grep HostPort | sed 's/[^0-9]//g')

URL="http://127.0.0.1:$port/identity"
if [ "$container"=="jf" ]; then URL="http://127.0.0.1:$port/health"; fi

STATUS_CODE=$(curl -m 20 -s -o /dev/null -w "%{http_code}" ${URL})

if test $STATUS_CODE -ne 200; then
  if [ -z "$2" ]; then /usr/bin/docker restart "$container"; fi
#  /bin/echo "Restarted $server server at $(/bin/date)" >> /opt/logs/plex_restart.log
  exit 0
else
  echo "Failed"
  exit 1
fi
