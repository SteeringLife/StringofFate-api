# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  StringofFate::Platform.map(&:destroy)
  StringofFate::Link.map(&:destroy)
  StringofFate::Card.map(&:destroy)
  StringofFate::Account.map(&:destroy)
  StringofFate::PublicHashtag.map(&:destroy)
end

def auth_header(account_data)
  auth = StringofFate::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )

  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {
  accounts: YAML.safe_load(File.read('app/db/seeds/accounts_seed.yml')),
  links: YAML.safe_load(File.read('app/db/seeds/links_seed.yml')),
  platforms: YAML.safe_load(File.read('app/db/seeds/platforms_seed.yml')),
  cards: YAML.safe_load(File.read('app/db/seeds/cards_seed.yml')),
  public_hashtags: YAML.safe_load(File.read('app/db/seeds/public_hashtags_seed.yml'))
}.freeze
