#!/bin/bash

# Remove a potentially pre-existing server.pid for Rails.
# rm -f /app/tmp/pids/server.pid

# Start the main process.
yarn run dev
# bundle exec rails s -p 3000 -b '0.0.0.0'
