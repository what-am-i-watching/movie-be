# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Seed Users
puts "Creating users..."

user1 = User.find_or_create_by!(email: 'demo@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

user2 = User.find_or_create_by!(email: 'test@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

puts "Created users: #{User.count}"

# Seed Movies
puts "Creating movies..."

movies_data = [
  {
    tmdb_id: 603,
    title: 'The Matrix',
    release_date: '1999-03-31',
    poster_url: '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
    is_movie: true
  },
  {
    tmdb_id: 550,
    title: 'Fight Club',
    release_date: '1999-10-15',
    poster_url: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
    is_movie: true
  },
  {
    tmdb_id: 278,
    title: 'The Shawshank Redemption',
    release_date: '1994-09-23',
    poster_url: '/9cqN61F9bG7cxOBcALofZTkN6nL.jpg',
    is_movie: true
  },
  {
    tmdb_id: 27205,
    title: 'Inception',
    release_date: '2010-07-16',
    poster_url: '/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
    is_movie: true
  },
  {
    tmdb_id: 1396,
    title: 'Breaking Bad',
    release_date: '2008-01-20',
    poster_url: '/ggFHVNu6YYI5L9pCfOacjizRGt.jpg',
    is_movie: false
  },
  {
    tmdb_id: 1399,
    title: 'Game of Thrones',
    release_date: '2011-04-17',
    poster_url: '/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg',
    is_movie: false
  }
]

movies_data.each do |movie_attrs|
  Movie.find_or_create_by!(tmdb_id: movie_attrs[:tmdb_id]) do |movie|
    movie.title = movie_attrs[:title]
    movie.release_date = movie_attrs[:release_date]
    movie.poster_url = movie_attrs[:poster_url]
    movie.is_movie = movie_attrs[:is_movie]
  end
end

puts "Created movies: #{Movie.count}"

# Seed UserMovies
puts "Creating user movie associations..."

# User 1's watchlist
UserMovie.find_or_create_by!(user: user1, movie: Movie.find_by(tmdb_id: 603)) do |um|
  um.status = :watched
  um.rating = 5
  um.notes = 'One of my all-time favorites!'
end

UserMovie.find_or_create_by!(user: user1, movie: Movie.find_by(tmdb_id: 550)) do |um|
  um.status = :watched
  um.rating = 5
  um.notes = 'Mind-blowing plot twist'
end

UserMovie.find_or_create_by!(user: user1, movie: Movie.find_by(tmdb_id: 27205)) do |um|
  um.status = :watching
  um.rating = nil
  um.progress_notes = 'Need to finish this'
end

UserMovie.find_or_create_by!(user: user1, movie: Movie.find_by(tmdb_id: 1396)) do |um|
  um.status = :watched
  um.rating = 5
  um.notes = 'Best TV show ever!'
  um.progress_notes = 'Finished all seasons'
end

UserMovie.find_or_create_by!(user: user1, movie: Movie.find_by(tmdb_id: 1399)) do |um|
  um.status = :to_watch
  um.rating = nil
  um.notes = nil
end

# User 2's watchlist
UserMovie.find_or_create_by!(user: user2, movie: Movie.find_by(tmdb_id: 278)) do |um|
  um.status = :watched
  um.rating = 5
  um.notes = 'Classic masterpiece'
end

UserMovie.find_or_create_by!(user: user2, movie: Movie.find_by(tmdb_id: 27205)) do |um|
  um.status = :watched
  um.rating = 4
  um.notes = 'Great concept, complex plot'
end

UserMovie.find_or_create_by!(user: user2, movie: Movie.find_by(tmdb_id: 1396)) do |um|
  um.status = :watching
  um.rating = nil
  um.notes = 'On season 3'
  um.progress_notes = 'On season 3, episode 5'
end

puts "Created user movies: #{UserMovie.count}"

puts "\nSeed data created successfully!"
puts "Demo user: demo@example.com / password123"
puts "Test user: test@example.com / password123"
