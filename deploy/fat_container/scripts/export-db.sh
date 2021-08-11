#!/bin/bash
echo "Exporting db"
# @TODO:
set -o allexport
. /opt/appsmith/docker.env
set +o allexport
node export-db.js
echo "Exporting DONE"