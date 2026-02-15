require "faraday"
require "json"

class WatchService
    BASE_URL = "https://api.watchmode.com/v1"
    API_KEY = ENV["WATCH_MODE_API_KEY"]
    CACHE_EXPIRY = 1.hour

    def self.watch_details(tmdb_id, is_movie: true)
      cache_key = "tmdb_watch_details_#{tmdb_id}"

      Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
        endpoint = is_movie ? "movie" : "tv"
        url = "#{BASE_URL}/title/#{endpoint}-#{tmdb_id}/sources"

        response = Faraday.get(url) do |req|
          req.params["apiKey"] = API_KEY
          req.params["regions"] = "US"
        end

        if response.success?
          JSON.parse(response.body, symbolize_names: true)
        else
          Rails.logger.error "WATCH MODE API request failed with status: #{response.status}"
          { error: "API request failed", status: response.status }
        end
      end
    end
end
