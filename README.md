# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version: 3.4.7
* Rails version: 8.1.1

* System dependencies

The following gems were used:
```
gem 'rack-cors'
gem 'devise'
gem 'devise-jwt'
gem 'faraday'
gem 'dotenv-rails'
```

An API key for [The Movie Database](https://www.themoviedb.org/) is needed for this application. Get your [API key](https://developer.themoviedb.org/docs/getting-started) and add it into your .env file as `TMDB_API_KEY`.

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

Authentication has been set up using [devise](https://github.com/heartcombo/devise) and [devise-jwt](https://github.com/waiting-for-dev/devise-jwt).

# Logging In and Out Using Postman

## Create a new user
`POST: http://localhost:3000/users`

In the body, add raw JSON with the data for the user you want to create:

```
{
    "user": {
        "email": "user@example.com",
        "password": "password123"
    }
}
```

### Example response:
```
{
    "status": {
        "code": 200,
        "message": "Signed up successfully",
        "data": {
            "id": 4,
            "email": "user@example.com",
            "created_at": "2025-12-18T21:38:17.980Z",
            "updated_at": "2025-12-18T21:38:17.980Z",
            "jti": "16c6bd9b-7aad-4754-b928-78eaajilvf3gq4ber"
        }
    }
}
```

You can also see authorization token returned in the Headers of the response.

## Log out
`DELETE: http://localhost:3000/users/sign_out`

After a successful login, copy the authorization token from the response header (ex: `Bearer efgHuBUlGyugug...`).

Add the token to the delete request with `Authorization` as the key and the token as the value, including the "Bearer ".

### Example Response:
```
{
    "status": 200,
    "message": "Signed out successfully"
}
```

## Logging in
`POST: http://localhost:3000/users/sign_in`

In the body, add raw JSON with the data of an existing user:

```
{
    "user": {
        "email": "user@example.com",
        "password": "password123"
    }
}
```

### Example response:
```
{
    "status": {
        "code": 200,
        "message": "User signed in successfully",
        "data": {
            "id": 4,
            "email": "user@example.com",
            "created_at": "2025-12-18T21:38:17.980Z",
            "updated_at": "2025-12-18T21:38:17.980Z",
            "jti": "16c6bd9b-7aad-4754-b928-78eaajilvf3gq4ber"
        }
    }
}
```

# Searching for Movies

## Search
`GET: http://localhost:3000/movies/search?query=jurassic+park`

Add your own search term

### Example response:
```
{
    "movies": [
        {
            "tmdb_id": 329,
            "genre_ids": [
                12,
                878
            ],
            "title": "Jurassic Park",
            "overview": "A wealthy entrepreneur secretly creates a theme park featuring living dinosaurs drawn from prehistoric DNA. Before opening day, he invites a team of experts and his two eager grandchildren to experience the park and help calm anxious investors. However, the park is anything but amusing as the security systems go off-line and the dinosaurs escape.",
            "poster_path": "/bRKmwU9eXZI5dKT11Zx1KsayiLW.jpg",
            "release_date": "1993-06-11",
            "vote_average": 7.964,
            "vote_count": 17347
        },
        {
            "tmdb_id": 995456,
            "genre_ids": [
                99
            ],
            "title": "Jurassic Greatest Moments: Jurassic Park to Jurassic World",
            "overview": "Join the cast of \"Jurassic World Dominion\" as they relive their favorite unforgettable, action-packed and epic moments from the \"Jurassic World\" franchise.",
            "poster_path": "/tPdsrxdJBBIvJi5rwcnYGUoPAai.jpg",
            "release_date": "2022-06-04",
            "vote_average": 7.0,
            "vote_count": 12
        }
    ]
}
```

And if none match the search query
```
{
    "movies": []
}
```