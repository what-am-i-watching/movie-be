class UserMovie < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
  validate :rating_must_be_half_step

  enum :status, {
    to_watch: 0,
    watching: 1,
    watched: 2
  }

  private

  def rating_must_be_half_step
    return if rating.nil?

    errors.add(:rating, "must be in 0.5 increments") unless (rating * 2).to_i == (rating * 2)
  end
end
