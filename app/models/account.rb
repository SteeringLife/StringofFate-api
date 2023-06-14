# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module StringofFate
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_cards, class: :'StringofFate::Card', key: :owner_id

    many_to_many :received_cards,
                 class: :'StringofFate::Card',
                 join_table: :accounts_cards,
                 left_key: :receiver_id, right_key: :card_id

    one_to_many :private_hashtags, class: :'StringofFate::PrivateHashtag', key: :owner_id

    plugin :association_dependencies,
           owned_cards: :destroy,
           received_cards: :nullify,
           private_hashtags: :destroy

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password, :realname, :showname

    plugin :timestamps, update_on_create: true

    def self.create_github_account(github_account)
      create(username: github_account[:username],
             email: github_account[:email])
    end

    def cards
      owned_cards + received_cards
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = StringofFate::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          type: 'account',
          attributes: {
            username:,
            email:,
            realname:,
            showname:
          }
        }, options
      )
    end
  end
end
