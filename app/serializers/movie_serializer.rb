class MovieSerializer
  include JSONAPI::Serializer

  set_id { |movie| movie[:id] || movie["id"] }

  attribute :tmdb_id do |movie|
    movie[:id] || movie["id"]
  end

  attribute :genre_ids do |movie|
    movie[:genre_ids] || movie["genre_ids"]
  end

  attribute :title do |movie|
    movie[:original_title] || movie["original_title"]
  end

  attribute :overview do |movie|
    movie[:overview] || movie["overview"]
  end

  attribute :poster_path do |movie|
    movie[:poster_path] || movie["poster_path"]
  end

  attribute :release_date do |movie|
    movie[:release_date] || movie["release_date"]
  end

  attribute :vote_average do |movie|
    movie[:vote_average] || movie["vote_average"]
  end

  attribute :vote_count do |movie|
    movie[:vote_count] || movie["vote_count"]
  end

  set_type :movie
end
