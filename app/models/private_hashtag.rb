# frozen_string_literal: true

require 'json'
require 'sequel'

module StringofFate
  # Models a private hashtag
  class PrivateHashtag < Sequel::Model
    many_to_one :owner, class: :'StringofFate::Account'
    many_to_one :card, class: :'StringofFate::Card'

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

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          type: 'public_hashtag',
          attributes: {
            id:,
            content:
          },
          include: {
            card:,
            owner:
          }
        }, options
      )
    end
  end
end
