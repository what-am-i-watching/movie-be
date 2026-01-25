class Movie < ApplicationRecord
  has_many :user_movies
  has_many :users, through: :user_movies

  validates :tmdb_id, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than: 0 }
  validates :title, presence: true
  validates :release_date, presence: true
  validates :is_movie, inclusion: { in: [ true, false ] }
end
