#!/bin/bash

set -o nounset
CUSTOM_DOMAIN="$1"

cat <<EOF
jobs:
  - name: $CUSTOM_DOMAIN
    source: https://$CUSTOM_DOMAIN:443