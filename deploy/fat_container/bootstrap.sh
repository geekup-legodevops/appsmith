#!/usr/bin/env bash

set -e

# _js_escape 'some "string" value'
_js_escape() {
	jq --null-input --arg 'str' "$1" '$str'
}

check_initialized_db() {
  echo 'Check initialized database'
  dbPath='/data/mongodb'
  shouldPerformInitdb='true'
  #check for a few known paths (to determine whether we've already initialized and should thus skip our initdb scripts)
  if [ -n "$shouldPerformInitdb" ]; then
    for path in \
      "$dbPath/WiredTiger" \
      "$dbPath/journal" \
      "$dbPath/local.0" \
      "$dbPath/storage.bson" \
    ; do
      if [ -e "$path" ]; then
        shouldPerformInitdb=
        break
      fi
    done
  fi
  echo "shouldPerformInitdb"
  return $shouldPerformInitdb
}
  
init_database() {
  echo "Waiting 10s mongodb init"
  sleep 10;
  echo "Init database"
  if [ -n "$shouldPerformInitdb" ]; then
    #TODO: generate init file from bash.sh
	bash "/docker-entrypoint-initdb.d/mongo-init.js.sh" "$MONGO_USERNAME" "$MONGO_PASSWORD" > "/docker-entrypoint-initdb.d/mongo-init.js"
	mongo "127.0.0.1/${MONGO_DATABASE}" /docker-entrypoint-initdb.d/mongo-init.js
  echo "Seeding db done"

  # Mongodb start
  echo "Enable replica set"
  mongod --dbpath /data/mongodb --shutdown  || true
  echo "Fork process"
  openssl rand -base64 756 > /data/mongodb/key
  chmod go-rwx,u-wx /data/mongodb/key
  mongod --fork --port 27017 --dbpath /data/mongodb --logpath /data/mongodb/log --replSet mr1 --keyFile /data/mongodb/key --bind_ip localhost
  sleep 10;
  mongo mongodb://appsmith:appsmith@localhost/appsmith --eval 'rs.initiate()'
 fi
}

start_redis(){
  echo 'Update Redis config'
  REDIS_BASE_DIR="/etc/redis"
  ARGS=("$REDIS_BASE_DIR/redis.conf" "--daemonize" "no") 
  echo "starting redis-server"
	# Start installed services - Dependencies Layer
	exec redis-server "${ARGS}" &
}

start_mongodb(){
  echo 'Update Mongo config'
  MONGO_DB_PATH="/data/mongodb"
  MONGO_LOG_PATH="$MONGO_DB_PATH/log"
  touch "$MONGO_LOG_PATH"
  echo "Starting mongo"
  ## check shoud init 
  shouldPerformInitdb=check_initialized_db
  # Start installed MongoDB service - Dependencies Layer
  mongod --fork --port 27017 --dbpath /data/mongodb --logpath /data/mongodb/log
  # Run logic int database schema
  init_database
}

start_editor_application(){
  echo "Generating nginx configuration"
  cat /etc/nginx/conf.d/default.conf.template | envsubst "$(printf '$%s,' $(env | grep -Eo '^APPSMITH_[A-Z0-9_]+'))" | sed -e 's|\${\(APPSMITH_[A-Z0-9_]*\)}||g' > /etc/nginx/sites-available/default
  echo "Starting Nginx"
  # Start Nginx
  nginx 
}

start_rts_application(){
  cd /app && node server.js
}

configure_ssl(){
  echo "to be implement configure_ssl"
  #check domai n& confing ssh
    #then run script
    #update ngnix domain template
    #run certbot -> sign ssl
}

start_backend_application(){
  java -Dserver.port=8080 -Djava.security.egd='file:/dev/./urandom' -jar server.jar 2>&1 &
}

start_application(){
  start_editor_application
  start_backend_application
  start_rts_application
}

echo 'Checking env configuration'
# Check for enviroment vairalbes
if [[ -z "${APPSMITH_MAIL_ENABLED}" ]]; then
    unset APPSMITH_MAIL_ENABLED # If this field is empty is might cause application crash
fi

if [[ -z "${APPSMITH_OAUTH2_GITHUB_CLIENT_ID}" ]] || [[ -z "${APPSMITH_OAUTH2_GITHUB_CLIENT_SECRET}" ]]; then
    unset APPSMITH_OAUTH2_GITHUB_CLIENT_ID # If this field is empty is might cause application crash
    unset APPSMITH_OAUTH2_GITHUB_CLIENT_SECRET
fi

if [[ -z "${APPSMITH_OAUTH2_GOOGLE_CLIENT_ID}" ]] || [[ -z "${APPSMITH_OAUTH2_GOOGLE_CLIENT_SECRET}" ]]; then
    unset APPSMITH_OAUTH2_GOOGLE_CLIENT_ID # If this field is empty is might cause application crash
    unset APPSMITH_OAUTH2_GOOGLE_CLIENT_SECRET
fi

if [[ -z "${APPSMITH_GOOGLE_MAPS_API_KEY}" ]]; then
    unset APPSMITH_GOOGLE_MAPS_API_KEY
fi

if [[ -z "${APPSMITH_RECAPTCHA_SITE_KEY}" ]] || [[ -z "${APPSMITH_RECAPTCHA_SECRET_KEY}" ]] || [[ -z "${APPSMITH_RECAPTCHA_ENABLED}" ]]; then
    unset APPSMITH_RECAPTCHA_SITE_KEY # If this field is empty is might cause application crash
    unset APPSMITH_RECAPTCHA_SECRET_KEY
    unset APPSMITH_RECAPTCHA_ENABLED
fi


# Main Section
start_redis
start_mongodb
start_application

