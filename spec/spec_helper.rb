# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  StringofFate::Account.map(&:destroy)
  app.DB[:links].delete
  app.DB[:platforms].delete
end

DATA = {
  accounts: YAML.safe_load(File.read('app/db/seeds/accounts_seed.yml')),
  links: YAML.safe_load(File.read('app/db/seeds/links_seed.yml')),
  platforms: YAML.safe_load(File.read('app/db/seeds/platforms_seed.yml'))
}.freeze
