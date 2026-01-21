class UserMovie < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  enum :status, {
    to_watch: 0,
    watching: 1,
    watched: 2
  }
end
