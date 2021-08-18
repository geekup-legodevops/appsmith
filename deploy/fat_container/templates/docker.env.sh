#!/bin/bash

set -o nounset

MONGO_PASSWORD="$1"
ENCRYPTION_PASSWORD="$2"
ENCRYPTION_SALT="$3"

cat <<EOF
# Sentry
APPSMITH_SENTRY_DSN=

# Smart look
APPSMITH_SMART_LOOK_ID=

# Google OAuth
APPSMITH_OAUTH2_GOOGLE_CLIENT_ID=
APPSMITH_OAUTH2_GOOGLE_CLIENT_SECRET=

# Github OAuth
APPSMITH_OAUTH2_GITHUB_CLIENT_ID=
APPSMITH_OAUTH2_GITHUB_CLIENT_SECRET=

# Segment
APPSMITH_SEGMENT_KEY=

# RapidAPI
APPSMITH_RAPID_API_KEY_VALUE=
APPSMITH_MARKETPLACE_ENABLED=

# Optimizely
APPSMITH_OPTIMIZELY_KEY=

# Algolia Search (Docs)
APPSMITH_ALGOLIA_API_ID=
APPSMITH_ALGOLIA_API_KEY=
APPSMITH_ALGOLIA_SEARCH_INDEX_NAME=

#Client log level (debug | error)
APPSMITH_CLIENT_LOG_LEVEL=

# GOOGLE client API KEY
APPSMITH_GOOGLE_MAPS_API_KEY=

# Email server
APPSMITH_MAIL_ENABLED=
APPSMITH_MAIL_HOST=
APPSMITH_MAIL_PORT=
APPSMITH_MAIL_USERNAME=
APPSMITH_MAIL_PASSWORD=

# Email server feature toggles
# true | false values
APPSMITH_MAIL_SMTP_AUTH=
APPSMITH_MAIL_SMTP_TLS_ENABLED=

# Disable all telemetry
# Note: This only takes effect in self-hosted scenarios. 
# Please visit: https://docs.appsmith.com/v/v1.2.1/setup/telemetry to read more about anonymized data collected by Appsmith
# APPSMITH_DISABLE_TELEMETRY=false

#APPSMITH_SENTRY_DSN=
#APPSMITH_SENTRY_ENVIRONMENT=

# Configure cloud services
# APPSMITH_CLOUD_SERVICES_BASE_URL="https://release-cs.appsmith.com"

# Google Recaptcha Config
APPSMITH_RECAPTCHA_SITE_KEY=
APPSMITH_RECAPTCHA_SECRET_KEY=
APPSMITH_RECAPTCHA_ENABLED=

APPSMITH_MONGO_USERNAME=appsmith
APPSMITH_MONGO_PASSWORD=$MONGO_PASSWORD
APPSMITH_MONGO_DATABASE=appsmith
APPSMITH_MONGO_HOST=localhost:27017
APPSMITH_MONGODB_URI=mongodb://appsmith:$MONGO_PASSWORD@localhost/appsmith
APPSMITH_API_BASE_URL=http://localhost:8080

APPSMITH_REDIS_URL=redis://127.0.0.1:6379

APPSMITH_MAIL_ENABLED=false

APPSMITH_ENCRYPTION_PASSWORD=$ENCRYPTION_PASSWORD
APPSMITH_ENCRYPTION_SALT=$ENCRYPTION_SALT

APPSMITH_CUSTOM_DOMAIN=
EOF
