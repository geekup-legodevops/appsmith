#!/bin/bash

set -o nounset
MONGODB_URI="$1"

MONGODB_PROTOCOL=$(echo "$MONGODB_URI" | grep -oP "[a-z+]+(?=\:\/\/)")
MONGODB_PASSWORD=$(echo "$MONGODB_URI" | grep -oP "\w+(?=@)")
MONGODB_HOST=$(echo "$MONGODB_URI" | grep -oP "[a-z0-9.]+(?=\/)")
MONGODB_DATABASE=$(echo "$MONGODB_URI" | grep -oP "\w+(?!\S)")

if ! [[ "$MONGODB_PROTOCOL" = "mongodb" ]]; then
  echo "This protocol is not currently supported by Netdata"
	exit 0
fi

cat <<EOF
priority: 650
mongodb:
  name: ''
  authdb: '$MONGODB_DATABASE'
  host : '$MONGODB_HOST'
  port : 27017
  user : 'netdata'
  pass : '$MONGODB_PASSWORD'
EOF