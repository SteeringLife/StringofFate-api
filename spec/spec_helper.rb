# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:links].delete
  app.DB[:platforms].delete
  app.DB[:accounts].delete
end

DATA = {} # a hash # rubocop:disable Style/MutableConstant
DATA[:links] = YAML.safe_load File.read('app/db/seeds/links_seed.yml')
DATA[:platforms] = YAML.safe_load File.read('app/db/seeds/platforms_seed.yml')
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/accounts_seed.yml')
