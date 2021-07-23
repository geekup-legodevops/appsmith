FROM debian:buster

# Update APK packages - Base Layer
RUN apt-get update

# Install services - Service Layer
RUN apt-get install certbot nginx redis gnupg wget openjdk-11-jre -y

# Install node v14 - Service Layer
RUN wget https://nodejs.org/dist/v14.15.4/node-v14.15.4-linux-x64.tar.xz 
RUN	tar -xf node-v14.15.4-linux-x64.tar.xz 
RUN	cp -P node-v14.15.4-linux-x64/bin/node /usr/local/bin/ 
RUN	update-alternatives --install /usr/bin/node node /usr/local/bin/node 1 

# Install MongoDB v4.0.5 - LService Layer
RUN wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - 
RUN	echo "deb [ arch=amd64,arm64 ]http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list 
RUN	apt-get update 
RUN	apt-get install -y mongodb-org=4.4.6 

# Define volumes - Service Layer
VOLUME [ "/etc/letsencrypt", "/var/www/certbot", "/data/db" ]

# Add backend server - Application Layer
ARG JAR_FILE=./app/server/appsmith-server/target/server-*.jar
ARG PLUGIN_JARS=./app/server/appsmith-plugins/*/target/*.jar
ARG APPSMITH_SEGMENT_CE_KEY
ENV APPSMITH_SEGMENT_CE_KEY=${APPSMITH_SEGMENT_CE_KEY}

#Create the plugins directory
RUN mkdir -p /plugins

#Add the jar to the container. Always keep this at the end. This is to ensure that all the things that can be taken
#care of via the cache happens. The following statement would lead to copy because of change in hash value
COPY ./app/server/entrypoint.sh /entrypoint.sh
COPY ${JAR_FILE} server.jar
COPY ${PLUGIN_JARS} /plugins/

# Add client UI - Application Layer
COPY ./app/client/build /var/www/appsmith

# This is the default nginx template file inside the container. 
# This is replaced by the install.sh script during a deployment
COPY ./app/client/docker/templates/nginx-app.conf.template /nginx.conf.template
COPY ./app/client/docker/templates/nginx-root.conf.template /nginx-root.conf.template

# This is the script that is used to start Nginx when the Docker container starts
COPY ./app/client/docker/start-nginx.sh /start-nginx.sh

# Add RTS - Application Layer

COPY ./app/rts/package.json ./app/rts/yarn.lock ./app/rts/dist/* /app/

RUN rm -rf \
    /root/.cache \
    /root/.npm \
    /root/.pip \
    /usr/local/share/doc \
    /usr/share/doc \
    /usr/share/man \
    /usr/share/vim/vim74/doc \
    /usr/share/vim/vim74/lang \
    /usr/share/vim/vim74/spell/en* \
    /usr/share/vim/vim74/tutor \
    /var/lib/apt/lists/* \
    /tmp/*

COPY bootstrap.sh /bootstrap.sh

EXPOSE 80

ENTRYPOINT [ "/bin/sh -c" ]

CMD ["/bootstrap.sh"]