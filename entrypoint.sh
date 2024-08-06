#!/bin/bash
set -e

echo "Running entrypoint script..."

# Check if environment variable indicates Rails web container
if [[ ! -z "${RAILS_WEB_CONTAINER}" ]]; then
  echo "Running entrypoint script for Rails web container..."
else
  echo "Skipping database migrations for non-Rails web container."
  # Execute the container's main process (what's set as CMD in the Dockerfile).
  exec "$@"
fi

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid
echo "Removed existing server.pid file"

# Function to check and migrate the database
migrate_database() {
  local env=$1
  echo "Migrating database for $env environment..."

  # Check if the database exists
  if ! RAILS_ENV=$env rails db:version > /dev/null 2>&1; then
    echo "$env database does not exist. Creating and migrating..."
    RAILS_ENV=$env rails db:create db:migrate
  else
    echo "$env database already exists. Running migrations..."
    RAILS_ENV=$env rails db:migrate
  fi

  # Seed the development database only
  if [[ "$env" == "development" ]]; then
    echo "Seeding development database..."
    RAILS_ENV=$env rails db:seed
  fi
}

# Migrate the development database
migrate_database "development"

# Migrate the test database
migrate_database "test"

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
