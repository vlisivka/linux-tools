#!/bin/bash
set -ue
export LANG=C

if (( $#!=1 )); then
  echo "Usage:
   watch -n 1 -d  nettop.sh PORT
"
  exit 1
fi

netstat -an4tu | grep -F ESTABLISHED | grep -oE '[0-9\.]+:'"$1" | cut -d ':' -f 1 | perl -MSocket -anle 'print($_, " ", (gethostbyaddr(inet_aton($_), AF_INET))[0])' |  sort -n | uniq -c | sort -nr
