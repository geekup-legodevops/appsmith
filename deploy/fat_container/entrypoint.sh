#!/usr/bin/env bash

set -e

# # _js_escape 'some "string" value'
# _js_escape() {
# 	jq --null-input --arg 'str' "$1" '$str'
# }

check_initialized_db() {
  echo 'Check initialized database'
  shouldPerformInitdb=1
  #check for a few known paths (to determine whether we've already initialized and should thus skip our initdb scripts)
  for path in \
	"$MONGO_DB_PATH/WiredTiger" \
	"$MONGO_DB_PATH/journal" \
	"$MONGO_DB_PATH/local.0" \
	"$MONGO_DB_PATH/storage.bson" \
  ; do
	if [ -e "$path" ]; then
	  shouldPerformInitdb=0
	  return
	fi
  done
  echo "Should initialize database"
}
  
init_mongodb() {
  echo "Init database"
  MONGO_DB_PATH="/opt/appsmith/data/mongodb"
  MONGO_LOG_PATH="$MONGO_DB_PATH/log"
  MONGO_DB_KEY="$MONGO_DB_PATH/key"
  touch "$MONGO_LOG_PATH"
  ## check shoud init 
  check_initialized_db
  ## Init appmsimth schema
  if [[ $shouldPerformInitdb -gt 0 ]]; then
	# Start installed MongoDB service - Dependencies Layer
	mongod --fork --port 27017 --dbpath "$MONGO_DB_PATH" --logpath "$MONGO_LOG_PATH"
	echo "Waiting 10s for mongodb init"
	sleep 10;
    bash "/opt/appsmith/configuration/mongo-init.js.sh" "$MONGO_USERNAME" "$MONGO_PASSWORD" > "/opt/appsmith/configuration/mongo-init.js"
    mongo "127.0.0.1/${MONGO_DATABASE}" /opt/appsmith/configuration/mongo-init.js
    echo "Seeding db done"

    # Mongodb start
    echo "Enable replica set"
    mongod --dbpath "$MONGO_DB_PATH" --shutdown || true
    echo "Fork process"
    openssl rand -base64 756 > "$MONGO_DB_KEY"
    chmod go-rwx,u-wx "$MONGO_DB_KEY"
    mongod --fork --port 27017 --dbpath "$MONGO_DB_PATH" --logpath "$MONGO_LOG_PATH" --replSet mr1 --keyFile "$MONGO_DB_KEY" --bind_ip localhost
    echo "Waiting 10s for mongodb init with replica set"
    sleep 10;
    mongo "$APPSMITH_MONGODB_URI" --eval 'rs.initiate()'
    mongod --dbpath "$MONGO_DB_PATH" --shutdown || true
  fi
}

# start_redis(){
#   echo 'Update Redis config'
#   REDIS_BASE_DIR="/etc/redis"
#   ARGS=("$REDIS_BASE_DIR/redis.conf" "--daemonize" "no") 
#   echo "Starting redis-server"
#   # Start installed services - Dependencies Layer
#   exec redis-server "${ARGS}" &
# }

# start_mongodb(){
  
  
# 	# Run logic int database schema
# 	init_database
# #   else
# # 	mongod --fork --port 27017 --dbpath /data/mongodb --logpath /data/mongodb/log --replSet mr1 --keyFile /data/mongodb/key --bind_ip localhost
# #   	echo "Waiting 10s for mongodb init with replica set"
# #   	sleep 10;
#   fi
# }

init_ssl_cert(){
	local domain="$1"
	NGINX_SSL_CMNT=""

	local rsa_key_size=4096
    local data_path="/opt/appsmith/data/certificate"

	mkdir -p "$data_path"/{conf,www}

    if ! [[ -e "$data_path/conf/options-ssl-nginx.conf" && -e "$data_path/conf/ssl-dhparams.pem" ]]; then
        echo "Downloading recommended TLS parameters..."
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf >"$data_path/conf/options-ssl-nginx.conf"
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem >"$data_path/conf/ssl-dhparams.pem"
        echo
    fi

	echo "Re-generating nginx config template with domain"
    bash "/opt/appsmith/configuration/nginx_app.conf.sh" "$NGINX_SSL_CMNT" "$CUSTOM_DOMAIN" > "/etc/nginx/conf.d/nginx_app.conf.template"

    echo "Generating nginx configuration"
    cat /etc/nginx/conf.d/nginx_app.conf.template | envsubst "$(printf '$%s,' $(env | grep -Eo '^APPSMITH_[A-Z0-9_]+'))" | sed -e 's|\${\(APPSMITH_[A-Z0-9_]*\)}||g' > /etc/nginx/sites-available/default

	local live_path="/etc/letsencrypt/live/$domain"
	if [[ -e "$live_path" ]]; then
		echo "Existing certificate for domain $domain"
		nginx -s reload
		return
	fi

	echo "Creating certificate for '$domain'"

	echo "Requesting Let's Encrypt certificate for '$domain'..."
	echo "Generating OpenSSL key for '$domain'..."
    
	mkdir -p "$live_path" && openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
		-keyout "$live_path/privkey.pem" \
		-out "$live_path/fullchain.pem" \
		-subj "/CN=localhost"

	#reload Nginx
	echo
	echo "Reload Nginx"
	nginx -s reload

	echo "Removing key now that validation is done for $domain..."
	rm -Rfv /etc/letsencrypt/live/$domain /etc/letsencrypt/archive/$domain /etc/letsencrypt/renewal/$domain.conf
    echo

	echo "Generating certification for domain $domain"
	certbot certonly --webroot --webroot-path="$data_path/certbot" \
            --register-unsafely-without-email \
            --domains $domain \
            --rsa-key-size $rsa_key_size \
            --agree-tos \
            --force-renewal

	echo "Reload nginx"
	nginx -s reload
}

configure_ssl(){
  #check domain & confing ssh
  NGINX_SSL_CMNT="#"

  echo "Generating nginx config template without domain"
  bash "/opt/appsmith/configuration/nginx_app.conf.sh" "$NGINX_SSL_CMNT" "$CUSTOM_DOMAIN" > "/etc/nginx/conf.d/nginx_app.conf.template"

  echo "Generating nginx configuration"
  cat /etc/nginx/conf.d/nginx_app.conf.template | envsubst "$(printf '$%s,' $(env | grep -Eo '^APPSMITH_[A-Z0-9_]+'))" | sed -e 's|\${\(APPSMITH_[A-Z0-9_]*\)}||g' > /etc/nginx/sites-available/default
  nginx
  
  if [[ -n $CUSTOM_DOMAIN ]]; then
    #then run script
	init_ssl_cert "$CUSTOM_DOMAIN"
  fi
  nginx -s stop
}

configure_supervisord(){
	SUPERVISORD_CONF_PATH="/opt/appsmith/configuration/supervisord"
	if [ -e "/etc/supervisor/conf.d/"*.conf ]; then
		rm "/etc/supervisor/conf.d/"*
	fi

	cp -f "$SUPERVISORD_CONF_PATH/application_process/"*.conf /etc/supervisor/conf.d
	if [[ "$APPSMITH_MONGODB_URI" = "mongodb://appsmith:appsmith@localhost/appsmith" ]]; then
		cp "$SUPERVISORD_CONF_PATH/mongodb.conf" /etc/supervisor/conf.d/
	fi
	if [[ "$APPSMITH_REDIS_URL" = "redis://127.0.0.1:6379" ]]; then
		cp "$SUPERVISORD_CONF_PATH/redis.conf" /etc/supervisor/conf.d/
	fi
}

# start_backend_application(){
#   java -Dserver.port=8080 -Djava.security.egd='file:/dev/./urandom' -jar server.jar 2>&1 &
# }

# start_rts_application(){
#   cd /app && node server.js
# }

# start_application(){
#   start_backend_application
#   start_rts_application
# }

echo 'Checking existing configuration file'
if ! [[ -e "/opt/appsmith/docker.env" ]]; then
	echo "Generating configuration environment file"
	bash "/opt/appsmith/configuration/docker.env.sh" > "/opt/appsmith/docker.env"
fi

echo 'Load environment configuration'
set -o allexport
. /opt/appsmith/docker.env
set +o allexport

# Check for enviroment vairalbes
echo 'Checking environment configuration'
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
#start_redis
init_mongodb
configure_ssl
#start_application
configure_supervisord
exec "$@"