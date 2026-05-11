#!/bin/sh

current_time=$(date "+%Y-%m-%d-%H%M")
logFileName=logs/charging-$current_time.log

/usr/bin/java \
  -Dspring.datasource.username=defaultDbUser \
  -Dspring.datasource.password=${POSTGRES_DB_PASSWORD} \
  -Dspring.security.oauth2.resourceserver.jwt.issuer-uri="https://${KEYCLOAK_DOMAIN}/realms/momosi" \
  -Dapplication.station.cloudStatusUrl=${STATION_STATUS_URL} \
  -Dapplication.station.cloudSetUrl=${STATION_SET_URL} \
  -Dapplication.station.cloudToken=${STATION_TOKEN} \
  -Dapplication.station.cloudDownload=${STATION_DOWNLOAD} \
  -Dapplication.station.cloudDownloadToken=${STATION_DOWNLOAD_TOKEN} \
  -jar ../module-server/module-server.jar
