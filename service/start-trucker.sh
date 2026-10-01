#!/bin/sh

current_time=$(date "+%Y-%m-%d-%H%M")
logFileName=logs/charging-$current_time.log

/usr/bin/java \
  -Dspring.datasource.username=defaultDbUser \
  -Dspring.datasource.password=${POSTGRES_DB_PASSWORD} \
  -Dspring.security.oauth2.resourceserver.jwt.issuer-uri="https://${KEYCLOAK_DOMAIN}/realms/trucktrack" \
  -Ds3.endpoint=${S3_ENDPOINT} \
  -Ds3.access-key=${S3_ACCESS_KEY} \
  -Ds3.secret-key=${S3_SECRET_KEY} \
  -Dserver.port=8085 \
  -Dspring.servlet.multipart.max-file-size="15MB" \
  -Dspring.servlet.multipart.max-request-size="15MB" \
  -jar ../module-server-tt/module-server.jar
