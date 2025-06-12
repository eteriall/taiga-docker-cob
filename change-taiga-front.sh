#!/bin/bash

set -e

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_LOGO_PATH="$PROJECT_DIR/logo.png"
CONTAINER_NAME="taiga-docker-taiga-front-1"

cd taiga-front
nvm install
nvm use
npm ci
npx gulp deploy
cd ..

DIST_PATH="$PROJECT_DIR/taiga-front/dist"
find "$DIST_PATH" -type f \( -name "*.js" -o -name "*.html" -o -name "*.css" \) -exec sed -i '' \
  -e 's/"Taiga"/"Copernicus Berlin"/g' \
  -e "s/'Taiga'/'Copernicus Berlin'/g" \
  -e 's/>Taiga</>Copernicus Berlin</g' \
  -e 's/Taiga<\/title>/Copernicus Berlin<\/title>/g' \
  {} +

docker cp "$DIST_PATH/." "$CONTAINER_NAME:/usr/share/nginx/html/"

VERSION_DIRS=$(docker exec "$CONTAINER_NAME" sh -c 'ls /usr/share/nginx/html | grep "^v-"')

for VERSION in $VERSION_DIRS; do
  LOGO_DEST_PATH="/usr/share/nginx/html/$VERSION/images/favicon.png"
  docker cp "$LOCAL_LOGO_PATH" "$CONTAINER_NAME:$LOGO_DEST_PATH"
done

docker restart "$CONTAINER_NAME"

