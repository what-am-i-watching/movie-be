if Rails.env.production?
  Rails.application.config.session_store :cookie_store, 
    key: '_my_watchlist_session', 
    domain: :all, # Or your specific domain
    tld_length: 2,
    secure: true,
    same_site: :none
else
  Rails.application.config.session_store :cookie_store, key: '_my_watchlist_session'
end