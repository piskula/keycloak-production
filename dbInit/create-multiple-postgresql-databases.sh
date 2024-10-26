#!/bin/bash

set -e
set -u

function create_user_and_database() {
	local database=$1
	echo "  Creating user and database '$database'"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	    CREATE USER $database;
	    CREATE DATABASE $database;
	    GRANT ALL PRIVILEGES ON DATABASE $database TO $database;
EOSQL
}

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
	echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"
	for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
		create_user_and_database $db
	done

# TODO delete default database, but we need to disconnect from it first and make some other default
#	echo "  Delete default database '$POSTGRES_USER'"
#	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
#      DROP DATABASE "$POSTGRES_USER";
#EOSQL

	echo "Multiple databases created"
fi
