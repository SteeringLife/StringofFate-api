# frozen_string_literal: true

require 'json'
require 'sequel'

module StringofFate
  # Models a secret document
  class Link < Sequel::Model
    many_to_one :owner_card, class: :'StringofFate::Account'
    many_to_one :platform, class: :'StringofFate::Platform'

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :url

    # Secure getters and setters
    def name
      SecureDB.decrypt(name_secure)
    end

    def name=(plaintext)
      self.name_secure = SecureDB.encrypt(plaintext)
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
          type: 'link',
          attributes: {
            id:,
            name:,
            url:
          },
          included: {
            ocard:,
            platform:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
