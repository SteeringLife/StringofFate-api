# frozen_string_literal: true

require 'json'
require 'sequel'

module StringofFate
  # Models a secret document
  class Link < Sequel::Model
    many_to_one :owner, class: :'StringofFate::Account'
    many_to_one :platform, class: :'StringofFate::Platform'

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :nickname, :url

    # Secure getters and setters
    def nickname
      SecureDB.decrypt(nickname_secure)
    end

    def nickname=(plaintext)
      self.nickname_secure = SecureDB.encrypt(plaintext)
    end

    def url
      SecureDB.decrypt(url_secure)
    end

    def url=(plaintext)
      self.url_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'link',
            attributes: {
              id:,
              nickname:,
              url:
            }
          },
          included: {
            owner:,
            platform:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
