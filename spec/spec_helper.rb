# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  StringofFate::PrivateHashtag.map(&:destroy)
  StringofFate::PublicHashtag.map(&:destroy)
  StringofFate::Link.map(&:destroy)
  StringofFate::Card.map(&:destroy)
  StringofFate::Account.map(&:destroy)
end

def authenticate(account_data)
  StringofFate::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)

  token = AuthToken.new(auth[:attributes][:auth_token])
  account = token.payload['attributes']
  { account: StringofFate::Account.first(username: account['username']),
    scope: AuthScope.new(token.scope) }
end
DATA = {
  accounts: YAML.safe_load(File.read('app/db/seeds/accounts_seed.yml')),
  links: YAML.safe_load(File.read('app/db/seeds/links_seed.yml')),
  platforms: YAML.safe_load(File.read('app/db/seeds/platforms_seed.yml')),
  cards: YAML.safe_load(File.read('app/db/seeds/cards_seed.yml')),
  public_hashtags: YAML.safe_load(File.read('app/db/seeds/public_hashtags_seed.yml')),
  private_hashtags: YAML.safe_load(File.read('app/db/seeds/private_hashtags_seed.yml'))
}.freeze

## SSO fixtures
GH_ACCOUNT_RESPONSE = YAML.load(
  File.read('spec/fixtures/github_token_response.yml')
)
GOOD_GH_ACCESS_TOKEN = GH_ACCOUNT_RESPONSE.keys.first
SSO_ACCOUNT = YAML.load(File.read('spec/fixtures/sso_account.yml'))
