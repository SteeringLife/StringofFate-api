# frozen_string_literal: true

require 'json'
require 'sequel'

module StringofFate
  # Models a platform
  class Hashtag < Sequel::Model
    one_to_many :account_hashtags
    plugin :association_dependencies, account_hashtags: :destroy

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
          type: 'hashtag',
          attributes: {
            id:,
            content:
          }
        }, options
      )
    end
  end
end
