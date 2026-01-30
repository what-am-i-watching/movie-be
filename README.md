# What Am I Watching? API

REST API for managing movies and TV shows watchlists.

Deployed app can be found at (whatamiwatching.info/)[https://whatamiwatching.info/]

## Getting Started

### Requirements

* Ruby version: 3.4.7
* Rails version: 8.1.1

### System Dependencies

The following gems are used:
```
gem 'rack-cors'
gem 'devise'
gem 'devise-jwt'
gem 'faraday'
gem 'dotenv-rails'
gem 'redis-rails'
gem 'jsonapi-serializer'
gem 'rswag'
```

### Configuration

An API key for [The Movie Database (TMDB)](https://www.themoviedb.org/) is required. Get your [API key](https://developer.themoviedb.org/docs/getting-started) and add it to your `.env` file as `TMDB_API_KEY`.

### Attribution

This product uses the TMDB API but is not endorsed or certified by TMDB. See [TMDB's attribution requirements](https://developer.themoviedb.org/docs/faq).

![TMDB Logo](images/tmdb-logo.svg)

## API Documentation

### Swagger UI (Development Only)

Interactive API documentation is available via Swagger UI in development:

**Development:** `http://localhost:3000/api-docs`

The Swagger UI provides:
- Complete API endpoint documentation
- Interactive testing interface
- Request/response schemas
- Authentication examples

You can test all endpoints directly from the Swagger UI by:
1. Signing in via `POST /users/sign_in` to get a JWT token
2. Clicking the "Authorize" button at the top
3. Entering your token (format: `Bearer <your-token>`)
4. Testing any authenticated endpoint

### OpenAPI Specification

The OpenAPI 3.0 specification is generated at `swagger/swagger.yaml` and can be:
- Imported into API clients like Postman, Insomnia
- Used for code generation
- Referenced for API integration

## Health Check Endpoints

These endpoints are not included in the Swagger documentation but are available for monitoring:

### GET /health

Returns detailed health status information. No authentication required.

**Response (200 OK):**
```json
{
  "status": "online",
  "database_connected": true,
  "existing_tables": ["users", "movies", "user_movies", ...],
  "solid_cache_exists": true,
  "rails_env": "development"
}
```

**Error Response (500):**
```json
{
  "error": "Error message",
  "backtrace": ["..."]
}
```

### GET /up

Simple health check endpoint for load balancers and uptime monitors. Returns 200 OK when the app is healthy, 500 when there are exceptions. No authentication required.

## Authentication

Authentication is implemented using [Devise](https://github.com/heartcombo/devise) and [Devise JWT](https://github.com/waiting-for-dev/devise-jwt).

### Getting a JWT Token

1. Register a new user: `POST /users` (see Swagger docs for request format)
2. Sign in: `POST /users/sign_in` (see Swagger docs for request format)
3. Copy the JWT token from the `Authorization` header in the response
4. Include it in subsequent requests: `Authorization: Bearer <token>`

### Protected Endpoints

Most endpoints require authentication. Include the JWT token in the `Authorization` header for all protected endpoints.

## Database

* Database creation: `rails db:create`
* Database initialization: `rails db:migrate`
* Database seeding: `rails db:seed`

## Testing

Run the test suite:
```bash
bundle exec rspec
```

Generate/update OpenAPI specification:
```bash
bundle exec rake rswag:specs:swaggerize
```

## Deployment

See deployment-specific configuration in:
- `config/deploy.yml` (Kamal deployment)
- `render.yaml` (Render deployment)
