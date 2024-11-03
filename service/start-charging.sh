#!/bin/sh

current_time=$(date "+%Y-%m-%d-%H%M")
logFileName=logs/charging-$current_time.log

/usr/bin/java \
  -Dspring.datasource.password=${POSTGRES_DB_PASSWORD} \
  -Dspring.security.oauth2.client.registration.keycloak.client-id=${KEYCLOAK_CLIENT_ID} \
  -Dspring.security.oauth2.client.registration.keycloak.client-secret=${KEYCLOAK_CLIENT_SECRET} \
  -jar ../module-server/module-server.jar
