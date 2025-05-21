#!/bin/bash
# Start MySQL
mysqld_safe &

# Wait for MySQL to be available
until mysqladmin ping --silent; do
  echo "Waiting for MySQL..."
  sleep 1
done

# Start your main app
exec "$@"
