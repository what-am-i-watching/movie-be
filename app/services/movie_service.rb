require 'faraday'
require 'json'

class MovieService
    BASE_URL = "https://api.themoviedb.org/3"
    API_KEY = ENV["TMDB_API_KEY"]

    def self.search_movies(query)
        url = "#{BASE_URL}/search/movie"

        response = Faraday.get(url) do |req|
            req.headers['Authorization'] = "Bearer #{API_KEY}"
            req.params['query'] = query
        end

        if response.success?
            JSON.parse(response.body, symbolize_names: true)
        else
            { error: "API request failed", status: response.status}
        end
    end
end