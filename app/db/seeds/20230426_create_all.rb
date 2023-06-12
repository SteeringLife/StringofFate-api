# frozen_string_literal: true

require './app/controllers/helpers.rb'
include StringofFate::SecureRequestHelpers

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, cards, links'
    create_accounts
    create_owned_cards
    create_links
    add_recievers
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_cards.yml")
CARD_INFO = YAML.load_file("#{DIR}/cards_seed.yml")
LINK_INFO = YAML.load_file("#{DIR}/links_seed.yml")
RECIEV_INFO = YAML.load_file("#{DIR}/cards_recievers.yml")

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

    StringofFate::CreateLink.call(
      auth: auth, card: card, link_data: link_info
    )
  end
end

def add_recievers
  reciev_info = RECIEV_INFO
  reciev_info.each do |reciev|
    card = StringofFate::Card.first(name: reciev['card_name'])

    auth_token = AuthToken.create(card.owner)
    auth = scoped_auth(auth_token)

    reciev['reciever_email'].each do |email|
      StringofFate::GiveCardToReciever.call(
        auth: auth, card: card, reciever_email: email
      )
    end
  end
end
