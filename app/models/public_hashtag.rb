# frozen_string_literal: true

require 'json'
require 'sequel'

module StringofFate
  # Models a platform
  class PublicHashtag < Sequel::Model
    one_to_many :account_hashtags

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

    def to_json(options = {})
      JSON(
        {
          type: 'public_hashtag',
          attributes: {
            id:,
            content:
          }
          include: {
            card:
          }, options
      )
    end
  end
end
