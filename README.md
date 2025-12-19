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