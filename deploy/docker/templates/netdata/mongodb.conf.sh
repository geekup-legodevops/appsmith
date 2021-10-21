#!/bin/bash

set -o nounset
MONGODB_URI="$1"

MONGODB_PASSWORD=$(echo "$MONGODB_URI" | grep -oP "\w+(?=@)")
MONGODB_HOST=$(echo "$MONGODB_URI" | grep -oP "[a-z0-9.]+(?=\/)")
MONGODB_DATABASE=$(echo "$MONGODB_URI" | grep -oP "\w+(?!\S)")

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