#!/usr/bin/env bash

set -e

# _js_escape 'some "string" value'
_js_escape() {
	jq --null-input --arg 'str' "$1" '$str'
}

check_initialized_db() {
  echo 'Check initialized database'
  dbPath='/data/mongodb'
  shouldPerformInitdb=1
  #check for a few known paths (to determine whether we've already initialized and should thus skip our initdb scripts)
  for path in \
	"$dbPath/WiredTiger" \
	"$dbPath/journal" \
	"$dbPath/local.0" \
	"$dbPath/storage.bson" \
  ; do
	if [ -e "$path" ]; then
	shouldPerformInitdb=0
	return
	fi
  done
  echo "Should initialize database"
}
  
init_database() {
  echo "Waiting 10s mongodb init"
  sleep 10;
  echo "Init database"
  if [[ $shouldPerformInitdb -gt 0 ]]; then
  ## Init appmsimth schema
    #TODO: generate init file from bash.sh
	bash "/docker-entrypoint-initdb.d/mongo-init.js.sh" "$MONGO_USERNAME" "$MONGO_PASSWORD" > "/docker-entrypoint-initdb.d/mongo-init.js"
	mongo "127.0.0.1/${MONGO_DATABASE}" /docker-entrypoint-initdb.d/mongo-init.js
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
  check_initialized_db

  # Start installed MongoDB service - Dependencies Layer
  exec mongod --port 27017 --dbpath "$MONGO_DB_PATH" --logpath "$MONGO_LOG_PATH" &
  
  # Run logic int database schema
  init_database
}

start_rts_application(){
  echo "TODO: start rts"
}

init_ssl_cert(){
	local domain="$1"
	NGINX_SSL_CMNT=""

	local rsa_key_size=4096
    local data_path="/data/certbot"
	ls /etc/letsencrypt/live

	if [[ -e "/etc/letsencrypt/live/$domain" ]]; then
		echo "Existing certificate for domain $domain"
		return
	fi

	echo "Creating certificate for '$domain'"

	mkdir -p "$data_path"/{conf,www}

    if ! [[ -e "$data_path/conf/options-ssl-nginx.conf" && -e "$data_path/conf/ssl-dhparams.pem" ]]; then
        echo "Downloading recommended TLS parameters..."
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf >"$data_path/conf/options-ssl-nginx.conf"
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem >"$data_path/conf/ssl-dhparams.pem"
        echo
    fi

	echo "Re-generating nginx config template with domain"
    bash "/etc/nginx/conf.d/nginx_app.conf.sh" "$NGINX_SSL_CMNT" "$CUSTOM_DOMAIN" > "/etc/nginx/conf.d/nginx_app.conf.template"

    echo "Generating nginx configuration"
    cat /etc/nginx/conf.d/nginx_app.conf.template | envsubst "$(printf '$%s,' $(env | grep -Eo '^APPSMITH_[A-Z0-9_]+'))" | sed -e 's|\${\(APPSMITH_[A-Z0-9_]*\)}||g' > /etc/nginx/sites-available/default

	echo "Requesting Let's Encrypt certificate for '$domain'..."
	echo "Generating OpenSSL key for '$domain'..."
    
	local live_path="/etc/letsencrypt/live/$domain"
	mkdir -p "$live_path" && openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
		-keyout "$live_path/privkey.pem" \
		-out "$live_path/fullchain.pem" \
		-subj "/CN=localhost"

	#reload Nginx
	echo "Reload Nginx"
	nginx -s reload

	echo "Removing key now that validation is done for $domain..."
	rm -Rfv /etc/letsencrypt/live/$domain /etc/letsencrypt/archive/$domain /etc/letsencrypt/renewal/$domain.conf
    echo

	echo "Generating certification for domain $domain"
	certbot certonly --webroot --webroot-path=/var/www/certbot \
            --register-unsafely-without-email \
            --domains $domain \
            --rsa-key-size $rsa_key_size \
            --agree-tos \
            --force-renewal

	ls /etc/letsencrypt/live

	echo "Reload nginx"
	nginx -s reload
}

configure_ssl(){
  #check domain & confing ssh
  NGINX_SSL_CMNT="#"

  echo "Generating nginx config template without domain"
  bash "/etc/nginx/conf.d/nginx_app.conf.sh" "$NGINX_SSL_CMNT" "$CUSTOM_DOMAIN" > "/etc/nginx/conf.d/nginx_app.conf.template"

  echo "Generating nginx configuration"
  cat /etc/nginx/conf.d/nginx_app.conf.template | envsubst "$(printf '$%s,' $(env | grep -Eo '^APPSMITH_[A-Z0-9_]+'))" | sed -e 's|\${\(APPSMITH_[A-Z0-9_]*\)}||g' > /etc/nginx/sites-available/default
  nginx
  
  if [[ -n $CUSTOM_DOMAIN ]]; then
    #then run script
	init_ssl_cert "$CUSTOM_DOMAIN"
  fi
}

start_backend_application(){
  java -Dserver.port=8080 -Djava.security.egd='file:/dev/./urandom' -jar server.jar
}

start_application(){
  start_backend_application
  #start_rts_application
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
configure_ssl
start_application

