#!/bin/bash
set -euo pipefail

echo "Starting database creation..."

export PGPASSWORD="$(cat /opt/bitnami/postgresql/secrets/password)"

# Always connect to postgres DB for CREATE DATABASE
DB="postgres"
USER="${POSTGRES_USER}"

create_db () {
  local db_name=$1
  local db_owner=$2

  echo "Checking database: $db_name"

  EXISTS=$(psql -U "$USER" -d "$DB" -tAc "SELECT 1 FROM pg_database WHERE datname='${db_name}'")

  if [ "$EXISTS" != "1" ]; then
    echo "Creating database: $db_name with owner: $db_owner"
    psql -U "$USER" -d "$DB" -c "CREATE DATABASE ${db_name} OWNER ${db_owner};"
  else
    echo "Database $db_name already exists"
  fi
}

# =========================
# DATABASE CREATION
# =========================

create_db accountdb accountuser
create_db authdb authuser
create_db transactiondb transactionuser
create_db documentdb documentuser
create_db keycloakdb keycloakuser

echo "Database creation completed"