# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module StringofFate
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_cards, class: :'StringofFate::Card', key: :owner_id

    many_to_many :recieved_cards,
                 class: :'StringofFate::Card',
                 join_table: :cards_recievers,
                 left_key: :reciever_id, right_key: :card_id

    one_to_many :private_hashtags, class: :'StringofFate::PrivateHashtag', key: :owner_id

    plugin :association_dependencies,
           owned_cards: :destroy,
           recieved_cards: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password, :realname, :showname

    plugin :timestamps, update_on_create: true

    def cards
      owned_cards + recieved_cards
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
