#!/bin/bash
echo "Importing db"
# @TODO:
set -o allexport
. /opt/appsmith/docker.env
set +o allexport
node import-db.js
echo "Import DB done"