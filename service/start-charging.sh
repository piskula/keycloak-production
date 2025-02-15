#!/bin/sh

current_time=$(date "+%Y-%m-%d-%H%M")
logFileName=logs/charging-$current_time.log

/usr/bin/java \
  -Dspring.datasource.username=defaultDbUser \
  -Dspring.datasource.password=${POSTGRES_DB_PASSWORD} \
  -Dspring.security.oauth2.client.registration.keycloak.client-id=${KEYCLOAK_CLIENT_ID} \
  -Dspring.security.oauth2.client.registration.keycloak.client-secret=${KEYCLOAK_CLIENT_SECRET} \
  -Dspring.security.oauth2.client.provider.keycloak.issuer-uri="https://${KEYCLOAK_DOMAIN}/realms/momosi" \
  -Dapplication.station.cloudStatusUrl=${STATION_STATUS_URL} \
  -Dapplication.station.cloudSetUrl=${STATION_SET_URL} \
  -Dapplication.station.cloudToken=${STATION_TOKEN} \
  -jar ../module-server/module-server.jar
