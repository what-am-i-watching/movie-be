class UserMovie < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true

  enum :status, {
    to_watch: 0,
    watching: 1,
    watched: 2
  }
end
