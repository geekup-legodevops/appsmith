FROM debian:buster

# Set workdir to /var/www
WORKDIR /var/www

# Update APK packages - Base Layer
RUN apt-get update && apt-get install -y certbot jq nginx redis gnupg wget curl vim gettext openjdk-11-jre 
RUN wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - 
RUN	echo "deb [ arch=amd64,arm64 ]http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list 
# Install services - Service Layer
# Install MongoDB v4.0.5, Redis
RUN apt-get update && apt-get install -y mongodb-org=4.4.6 

# Install node v14 - Service Layer
RUN wget https://nodejs.org/dist/v14.15.4/node-v14.15.4-linux-x64.tar.xz 
RUN	tar -xf node-v14.15.4-linux-x64.tar.xz 
RUN	cp -P node-v14.15.4-linux-x64/bin/node /usr/local/bin/ 
RUN	update-alternatives --install /usr/bin/node node /usr/local/bin/node 1 

## Clean up cache file - Service layer
# RUN rm -rf \
#     /root/.cache \
#     /root/.npm \
#     /root/.pip \
#     /usr/local/share/doc \
#     /usr/share/doc \
#     /usr/share/man \
#     /var/lib/apt/lists/* \
#     /tmp/*


# Define volumes - Service Layer
VOLUME [ "/etc/letsencrypt", "/var/www/certbot", "/data/mongodb" ]
# ------------------------------------------------------------------------
# Add backend server - Application Layer
ARG JAR_FILE=./app/server/appsmith-server/target/server-*.jar
ARG PLUGIN_JARS=./app/server/appsmith-plugins/*/target/*.jar
ARG APPSMITH_SEGMENT_CE_KEY
ENV APPSMITH_SEGMENT_CE_KEY=${APPSMITH_SEGMENT_CE_KEY}
#Create the plugins directory
RUN mkdir -p plugins

#Add the jar to the container. Always keep this at the end. This is to ensure that all the things that can be taken
#care of via the cache happens. The following statement would lead to copy because of change in hash value
COPY ${JAR_FILE} server.jar
COPY ${PLUGIN_JARS} plugins/

# ------------------------------------------------------------------------
# Add client UI - Application Layer
COPY ./app/client/build /var/www/appsmith

# ------------------------------------------------------------------------
# Add RTS - Application Layer
COPY  ./app/rts/package.json ./app/rts/yarn.lock ./app/rts/dist/* /app/
COPY ./app/rts/node_modules /app/node_modules

# ------------------------------------------------------------------------
# Nginx config - Configuration layer
COPY ./deploy/fat_container/nginx_app.conf.sh /etc/nginx/conf.d/nginx_app.conf.sh
# Mongodb confi - Configuration layer
COPY ./deploy/fat_container/mongo-init.js.sh /docker-entrypoint-initdb.d/mongo-init.js.sh

## Add bootstrapfile
COPY ./deploy/fat_container/init_database.sh init_database.sh
COPY ./deploy/fat_container/bootstrap.sh bootstrap.sh

RUN chmod +x init_database.sh
RUN chmod +x bootstrap.sh

EXPOSE 80
EXPOSE 443
# ENTRYPOINT [ "/bin/bash" ]
CMD ["/var/www/bootstrap.sh"]