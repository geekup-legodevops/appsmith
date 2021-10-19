#!/bin/bash

set -o nounset
MONGODB_URI="$1"

MONGODB_USERNAME=$(echo "$MONGODB_URI" | grep -oP "\w+(?=:\w)")
MONGODB_PASSWORD=$(echo "$MONGODB_URI" | grep -oP "\w+(?=@)")
MONGODB_HOST=$(echo "$MONGODB_URI" | grep -oP "\w+(?=\/)")
MONGODB_DATABASE=$(echo "$MONGODB_URI" | grep -oP "\w+(?!\S)")

cat <<EOF
priority: 650
mongodb:
  name: ''
  authdb: '$MONGODB_DATABASE'
  host : '$MONGODB_HOST'
  port : 27017
  user : '$MONGODB_USERNAME'
  pass : '$MONGODB_PASSWORD'
EOF