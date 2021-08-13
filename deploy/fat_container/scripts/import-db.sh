#!/bin/bash
echo "Importing db"
# @TODO:
set -o allexport
. /opt/appsmith/data/docker.env
set +o allexport
node import-db.js
echo "Import DB done"