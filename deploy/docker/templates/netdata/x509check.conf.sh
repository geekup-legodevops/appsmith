#!/bin/bash

set -o nounset
CUSTOM_DOMAIN="$1"

cat <<EOF
priority: 550
jobs:
  - name: $CUSTOM_DOMAIN
    source: https://$CUSTOM_DOMAIN:443
EOF