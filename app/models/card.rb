# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module StringofFate
  # Models a registered account
  class Card < Sequel::Model
    many_to_one :owner, class: :'StringofFate::Account'

    many_to_many :receivers,
                 class: :'StringofFate::Account',
                 join_table: :accounts_cards,
                 left_key: :card_id, right_key: :receiver_id

    one_to_many :links

    many_to_many :public_hashtags,
                 class: :'StringofFate::PublicHashtag',
                 join_table: :cards_public_hashtags,
                 left_key: :card_id, right_key: :public_hashtag_id

    one_to_many :private_hashtags

    plugin :association_dependencies,
           links: :destroy,
           receivers: :nullify,
           public_hashtags: :nullify,
           private_hashtags: :destroy

    plugin :whitelist_security
    set_allowed_columns :name, :description

    plugin :timestamps, update_on_create: true

    # Secure getters and setters
    def name
      SecureDB.decrypt(name_secure)
    end

    def name=(plaintext)
      self.name_secure = SecureDB.encrypt(plaintext)
    end

    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def to_h
      {
        type: 'card',
        attributes: {
          id:,
          name:,
          description:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner:,
          receivers:,
          links:,
          public_hashtags:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
