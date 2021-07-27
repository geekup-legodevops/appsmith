#!/usr/bin/env bash

set -e

# _js_escape 'some "string" value'
_js_escape() {
	jq --null-input --arg 'str' "$1" '$str'
}

init_database() {
  echo 'init_database'
  dbPath=/data/mongodb
  # shouldPerformInitdb='true'
  # check for a few known paths (to determine whether we've already initialized and should thus skip our initdb scripts)
  # if [ -n "$shouldPerformInitdb" ]; then
  #   for path in \
  #     "$dbPath/WiredTiger" \
  #     "$dbPath/journal" \
  #     "$dbPath/local.0" \
  #     "$dbPath/storage.bson" \
  #   ; do
  #     if [ -e "$path" ]; then
  #       shouldPerformInitdb=
  #       break
  #     fi
  #   done
  # fi
  echo "shouldPerformInitdb"
  echo $shouldPerformInitdb

  echo "Waiting 10s mongodb init"
  sleep 10;

  echo "Init database"
 if [ -n "$shouldPerformInitdb" ]; then
  ## Create user from env variable -> TODO: debug
    # mongo=( mongo --host 127.0.0.1 --port 27017 --quiet )
		# if [ "$MONGO_USERNAME" ] && [ "$MONGO_PASSWORD" ]; then
		# 	rootAuthDatabase='admin'
		# 	"${mongo[@]}" "$rootAuthDatabase" <<-EOJS
		# 		db.createUser({
		# 			user: $(_js_escape "$MONGO_USERNAME"),
		# 			pwd: $(_js_escape "$MONGO_PASSWORD"),
		# 			roles: [ { role: 'root', db: $(_js_escape "$rootAuthDatabase") } ]
		# 		})
		# 	EOJS
		# fi
  ## Init appmsimth schema
    #TODO: generate init file from bash.sh
		mongo "127.0.0.1/${MONGO_DATABASE}" /docker-entrypoint-initdb.d/init.js
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
  echo "starting mongo"
  ## check shoud init 
  #varaible=check_int
	exec mongod --port 27017 --dbpath "$MONGO_DB_PATH" --logpath "$MONGO_LOG_PATH" &
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
  echo "TODO: start rts"
}

configure_ssl(){
  echo "to be implement configure_ssl"
  #check domai n& confing ssh
    #then run script
    #update ngnix domain template
    #run certbot -> sign ssl
}

start_backend_application(){
  java -Dserver.port=8080 -Djava.security.egd='file:/dev/./urandom' -jar server.jar
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

