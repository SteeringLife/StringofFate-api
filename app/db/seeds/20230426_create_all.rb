# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts'
    create_accounts
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    StringofFate::Account.create(account_info)
  end
end
