# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_ngo-project_session',
  :secret      => '9106bd61a946e617eda1fc94c41570ae93780b149899276facef4dd9c215c16f2bb02dc61c9e0ce0d474ba2eceb6bfc2d05bc38e97fafa0b691f210bd63c4233'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
