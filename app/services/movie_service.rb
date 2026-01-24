require "faraday"
require "json"

class MovieService
    BASE_URL = "https://api.themoviedb.org/3"
    API_KEY = ENV["TMDB_API_KEY"]
    CACHE_EXPIRY = 1.hour

    def self.search_movies(query)
        cache_key = "tmdb_movies_search_#{query.parameterize}"

        Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
          url = "#{BASE_URL}/search/movie"

          response = Faraday.get(url) do |req|
              req.headers["Authorization"] = "Bearer #{API_KEY}"
              req.params["query"] = query
          end

          if response.success?
              JSON.parse(response.body, symbolize_names: true)
          else
              Rails.logger.error "TMDB API request failed with status: #{response.status}"
              { error: "API request failed", status: response.status }
          end
        end
    end

    def self.popular_movies
      cache_key = "tmdb_movies_popular"

      Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
        url = "#{BASE_URL}/movie/popular"

        response = Faraday.get(url) do |req|
            req.headers["Authorization"] = "Bearer #{API_KEY}"
        end

        if response.success?
            JSON.parse(response.body, symbolize_names: true)
        else
            Rails.logger.error "TMDB API request failed with status: #{response.status}"
            { error: "API request failed", status: response.status }
        end
      end
    end

    def self.movie_details(tmdb_id, is_movie: true)
      cache_key = "tmdb_#{is_movie ? 'movie' : 'tv'}_details_#{tmdb_id}"

      Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
        endpoint = is_movie ? "movie" : "tv"
        url = "#{BASE_URL}/#{endpoint}/#{tmdb_id}"

        response = Faraday.get(url) do |req|
          req.headers["Authorization"] = "Bearer #{API_KEY}"
        end

        if response.success?
          JSON.parse(response.body, symbolize_names: true)
        else
          Rails.logger.error "TMDB API request failed with status: #{response.status}"
          { error: "API request failed", status: response.status }
        end
      end
    end
end
