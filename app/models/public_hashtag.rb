# frozen_string_literal: true

require 'json'
require 'sequel'

module StringofFate
  # Models a platform
  class PublicHashtag < Sequel::Model
    many_to_many :cards,
                 class: :'StringofFate::Card',
                 join_table: :cards_public_hashtags,
                 left_key: :public_hashtag_id, right_key: :card_id

    plugin :association_dependencies, cards: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :content

    # Secure getters and setters
    def content
      SecureDB.decrypt(content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end

    def self.secure_find(content:)
      PublicHashtag.all.find { |public_hashtag| public_hashtag.content == content }
    end

    def to_json(options = {})
      JSON(
        {
          type: 'public_hashtag',
          attributes: {
            id:,
            content:
          }
        }, options
      )
    end
  end
end
