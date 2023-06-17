# frozen_string_literal: true

require './app/controllers/helpers'
include StringofFate::SecureRequestHelpers # rubocop:disable Style/MixinUsage

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, cards, links'
    create_accounts
    create_owned_cards
    create_links
    add_receivers
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_cards.yml")
CARD_INFO = YAML.load_file("#{DIR}/cards_seed.yml")
LINK_INFO = YAML.load_file("#{DIR}/links_seed.yml")
RECEIV_INFO = YAML.load_file("#{DIR}/cards_receivers.yml")


def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    StringofFate::Account.create(account_info)
  end
end

def create_owned_cards
  OWNER_INFO.each do |owner|
    account = StringofFate::Account.first(username: owner['username'])
    owner['card_name'].each do |card_name|
      card_data = CARD_INFO.find { |card| card['name'] == card_name }
      account.add_owned_card(card_data)
    end
  end
end

def create_links
  link_info_each = LINK_INFO.each
  cards_cycle = StringofFate::Card.all.cycle
  loop do
    link_info = link_info_each.next
    card = cards_cycle.next

    auth_token = AuthToken.create(card.owner)
    auth = scoped_auth(auth_token)

    StringofFate::CreateLink.call(auth:, card:, link_data: link_info)
  end
end

def add_receivers
  receiv_info = RECEIV_INFO
  receiv_info.each do |receiv|
    card = StringofFate::Card.first(name: receiv['card_name'])

    auth_token = AuthToken.create(card.owner)
    auth = scoped_auth(auth_token)

    receiv['receiver_email'].each do |email|
      StringofFate::GiveCardToReceiver.call(auth:, card:, receiver_email: email)
    end
  end
end
