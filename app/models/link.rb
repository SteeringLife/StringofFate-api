# frozen_string_literal: true

require 'json'
require 'sequel'

module StringofFate
  # Models a secret document
  class Link < Sequel::Model
    many_to_one :platform

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :nickname, :url

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
            platform:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
