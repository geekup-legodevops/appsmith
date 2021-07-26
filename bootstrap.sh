#!/usr/bin/env bash

set -e

# function get_maximum_heap(){ 
#     resource=$(ulimit -u)
#     echo "Resource : $resource"
#     if [[ "$resource" -le 256 ]]; then
#         maximum_heap=128
#     elif [[ "$resource" -le 512 ]]; then
#         maximum_heap=256
#     fi
# }


start_applcation(){
	# Start installed services - Dependencies Layer
	exec redis-server "${ARGS}" &
	exec mongod --port 27017 --dbpath "$MONGO_DB_PATH" --logpath "$MONGO_LOG_PATH" &

	# Create Nginx user
	exec useradd --no-create-home nginx
    # Start Nginx
	exec ./start-nginx.sh
	
    #if [[ ! -z ${maximum_heap} ]]; then
    #    backend_start_command="java -Xmx${maximum_heap}m -Dserver.port=8080 -Djava.security.egd='file:/dev/./urandom' -jar server.jar"
    #else
  	set -o allexport
	source .env
	backend_start_command="java -Dserver.port=8080 -Djava.security.egd='file:/dev/./urandom' -jar server.jar"
    #fi
    eval $backend_start_command

	# Start applicaions - Application Layer
	# cd /app
	# exec node server.js &
	# cd - 
}

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

cat /etc/nginx/conf.d/default.conf.template | envsubst "$(printf '$%s,' $(env | grep -Eo '^APPSMITH_[A-Z0-9_]+'))" | sed -e 's|\${\(APPSMITH_[A-Z0-9_]*\)}||g' > /etc/nginx/conf.d/default.conf.template.1

envsubst "\$PORT" < /etc/nginx/conf.d/default.conf.template.1 > /etc/nginx/conf.d/default.conf

#REDIS_BASE_DIR="$(whereis redis | grep -o '[^/s]*')"
REDIS_BASE_DIR="/etc/redis"
ARGS=("$REDIS_BASE_DIR/redis.conf" "--daemonize" "no") 

MONGO_DB_PATH="/data/db"
MONGO_LOG_PATH="$MONGO_DB_PATH/log"
touch "$MONGO_LOG_PATH"

#get_maximum_heap
start_applcation

