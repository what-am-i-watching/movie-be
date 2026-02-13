# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMovie, type: :model do
  describe 'rating validation' do
    let(:user) { User.create!(email: 'rating-test@example.com', password: 'password123', password_confirmation: 'password123') }
    let(:movie) { Movie.create!(title: 'Test', tmdb_id: 99999, release_date: '2020-01-01', is_movie: true) }

    it 'allows rating nil (optional)' do
      user_movie = UserMovie.new(user: user, movie: movie, status: :to_watch, rating: nil)
      expect(user_movie).to be_valid
    end

    it 'allows valid ratings 0 through 5' do
      [ 0, 1, 2, 3, 4, 5 ].each do |rating|
        user_movie = UserMovie.new(user: user, movie: movie, status: :to_watch, rating: rating)
        expect(user_movie).to be_valid, "expected rating #{rating} to be valid"
      end
    end

    it 'rejects rating less than 0' do
      user_movie = UserMovie.new(user: user, movie: movie, status: :to_watch, rating: -1)
      expect(user_movie).not_to be_valid
      expect(user_movie.errors[:rating]).to include('must be greater than or equal to 0')
    end

    it 'rejects rating greater than 5' do
      user_movie = UserMovie.new(user: user, movie: movie, status: :to_watch, rating: 6)
      expect(user_movie).not_to be_valid
      expect(user_movie.errors[:rating]).to include('must be less than or equal to 5')
    end
  end
end
