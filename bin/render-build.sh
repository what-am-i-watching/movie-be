#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
# If you have assets (even in an API, for the welcome page)
# bundle exec rake assets:precompile
# bundle exec rake assets:clean

bundle exec rails db:migrate
bundle exec rails db:migrate:cache
bundle exec rails db:migrate:queue
bundle exec rails db:migrate:cable
