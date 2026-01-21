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
    movie[:original_title] || movie["original_title"] || movie[:name] || movie["name"]
  end

  attribute :is_movie do |movie|
    movie[:is_movie] || movie["is_movie"]
  end

  attribute :overview do |movie|
    movie[:overview] || movie["overview"]
  end

  attribute :poster_path do |movie|
    movie[:poster_path] || movie["poster_path"]
  end

  attribute :release_date do |movie|
    movie[:release_date] || movie["release_date"] || movie[:first_air_date] || movie["first_air_date"]
  end

  attribute :vote_average do |movie|
    movie[:vote_average] || movie["vote_average"]
  end

  attribute :vote_count do |movie|
    movie[:vote_count] || movie["vote_count"]
  end

  attribute :status do |movie|
    movie[:status] || movie["status"]
  end

  attribute :progress_notes do |movie|
    movie[:progress_notes] || movie["progress_notes"]
  end

  attribute :rating do |movie|
    movie[:rating] || movie["rating"]
  end

  attribute :notes do |movie|
    movie[:notes] || movie["notes"]
  end

  attribute :in_list do |movie|
    movie[:in_list] || movie["in_list"]
  end

  set_type :movie
end
