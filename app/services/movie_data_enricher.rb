class MovieDataEnricher
  def self.enrich_with_user_data(movie_data, user)
    # Normalize movie_data to hash if it's an ActiveRecord object
    if movie_data.is_a?(Hash)
      movie_hash = movie_data.dup
      # Extract TMDB ID from the hash (could be in :id or :tmdb_id)
      tmdb_id_from_hash = movie_hash[:id] || movie_hash["id"] || movie_hash[:tmdb_id] || movie_hash["tmdb_id"]
    elsif movie_data.is_a?(ActiveRecord::Base)
      # For ActiveRecord objects, convert to hash
      movie_hash = movie_data.as_json.symbolize_keys
      movie_hash[:id] = movie_data.id
      movie_hash[:tmdb_id] = movie_data.tmdb_id
      tmdb_id_from_hash = movie_data.tmdb_id
    else
      movie_hash = movie_data.to_h.symbolize_keys
      tmdb_id_from_hash = movie_hash[:id] || movie_hash["id"] || movie_hash[:tmdb_id] || movie_hash["tmdb_id"]
    end

    # Find movie in database by tmdb_id (for ActiveRecord objects, we already have the movie)
    if movie_data.is_a?(Movie)
      db_movie = movie_data
      movie_hash[:id] = db_movie.id
      movie_hash[:tmdb_id] = db_movie.tmdb_id
    else
      # Try to find the movie in database by TMDB ID
      db_movie = Movie.find_by(tmdb_id: tmdb_id_from_hash)
      if db_movie
        movie_hash[:id] = db_movie.id
        movie_hash[:tmdb_id] = db_movie.tmdb_id
      else
        # Not in database, so id is nil, but keep tmdb_id from API
        movie_hash[:id] = nil
        movie_hash[:tmdb_id] = tmdb_id_from_hash
      end
    end

    # Handle TMDB's status field (e.g., "Released") - rename it to avoid conflict with user watch status
    if movie_hash.key?(:status) && !movie_hash[:status].in?([ "to_watch", "watching", "watched" ])
      movie_hash[:tmdb_status] = movie_hash.delete(:status)
    end

    if db_movie
      user_movie = user.user_movies.find_by(movie_id: db_movie.id)
      if user_movie
        movie_hash[:in_list] = true
        movie_hash[:user_movie_id] = user_movie.id
        movie_hash[:status] = user_movie.status
        movie_hash[:rating] = user_movie.rating
        movie_hash[:notes] = user_movie.notes
      else
        movie_hash[:in_list] = false
        movie_hash[:user_movie_id] = nil
        # Remove status if it's not a user watch status (should already be handled above, but be safe)
        movie_hash.delete(:status) unless movie_hash[:status].in?([ "to_watch", "watching", "watched" ])
      end
    else
      movie_hash[:in_list] = false
      movie_hash[:user_movie_id] = nil
      # Remove status if it's not a user watch status (should already be handled above, but be safe)
      movie_hash.delete(:status) unless movie_hash[:status].in?([ "to_watch", "watching", "watched" ])
    end

    # Set is_movie flag if not already set
    unless movie_hash.key?(:is_movie)
      movie_hash[:is_movie] = movie_hash.key?(:original_title) || movie_hash.key?("original_title")
    end

    normalize_fields!(movie_hash)

    movie_hash
  end

  def self.normalize_fields!(movie_hash)
    # Normalize title: always set title from original_title (movies) or name (shows)
    movie_hash[:title] ||= movie_hash[:original_title] ||
                          movie_hash["original_title"] ||
                          movie_hash[:name] ||
                          movie_hash["name"]

    # Normalize release_date: always set from release_date (movies) or first_air_date (shows)
    movie_hash[:release_date] ||= movie_hash[:release_date] ||
                                 movie_hash["release_date"] ||
                                 movie_hash[:first_air_date] ||
                                 movie_hash["first_air_date"]

    # Normalize poster_path: always set from poster_path (TMDB) or poster_url (database)
    movie_hash[:poster_path] ||= movie_hash[:poster_path] ||
                                movie_hash["poster_path"] ||
                                movie_hash[:poster_url] ||
                                movie_hash["poster_url"]
  end

  def self.enrich_collection(movies_data, user)
    movies_data.map { |movie| enrich_with_user_data(movie, user) }
  end
end
