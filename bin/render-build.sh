#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
# If you have assets (even in an API, for the welcome page)
# bundle exec rake assets:precompile
# bundle exec rake assets:clean

bundle exec rails db:migrate