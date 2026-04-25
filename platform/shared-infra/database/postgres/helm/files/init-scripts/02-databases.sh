#!/bin/bash
set -euo pipefail

echo "Starting database bootstrap..."

# Read password (Bitnami pattern)
export PGPASSWORD="$(cat /opt/bitnami/postgresql/secrets/password)"

DB="postgres"
USER="${POSTGRES_USER}"

# -----------------------------
# Utility: retry wrapper
# -----------------------------
retry() {
  local retries=5
  local delay=2
  local count=0

  until "$@"; do
    count=$((count + 1))
    if [ $count -ge $retries ]; then
      echo "Command failed after $retries attempts: $*"
      return 1
    fi
    echo "Retry $count/$retries..."
    sleep $delay
  done
}

# -----------------------------
# Wait for Postgres readiness
# -----------------------------
echo "Waiting for PostgreSQL to be ready..."

retry psql -U "$USER" -d "$DB" -c "SELECT 1" >/dev/null

echo "PostgreSQL is ready"

# -----------------------------
# Check if role exists
# -----------------------------
role_exists() {
  local role=$1
  psql -U "$USER" -d "$DB" -tAc "SELECT 1 FROM pg_roles WHERE rolname='${role}'" | grep -q 1
}

# -----------------------------
# Wait for role to be visible
# -----------------------------
wait_for_role() {
  local role=$1
  echo "Waiting for role: $role"

  retry role_exists "$role"

  echo "Role ready: $role"
}

# -----------------------------
# Create DB safely
# -----------------------------
create_db() {
  local db_name=$1
  local db_owner=$2

  echo "Checking database: $db_name"

  EXISTS=$(psql -U "$USER" -d "$DB" -tAc "SELECT 1 FROM pg_database WHERE datname='${db_name}'")

  if [ "$EXISTS" != "1" ]; then
    echo "Creating database: $db_name"

    # Step 1: Create DB
    retry psql -U "$USER" -d "$DB" -c "CREATE DATABASE ${db_name};"

    # Step 2: Wait for role visibility
    wait_for_role "$db_owner"

    # Step 3: Assign owner
    echo "Assigning owner: $db_owner"
    retry psql -U "$USER" -d "$DB" -c "ALTER DATABASE ${db_name} OWNER TO ${db_owner};"

    echo "Database ready: $db_name"
  else
    echo "Database already exists: $db_name"
  fi
}

# -----------------------------
# DATABASE LIST (easy to extend)
# -----------------------------
create_db accountdb accountuser
create_db authdb authuser
create_db transactiondb transactionuser
create_db documentdb documentuser
create_db keycloakdb keycloakuser

echo "Database bootstrap completed successfully"