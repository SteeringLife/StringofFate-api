# frozen_string_literal: true

require 'json'
require 'sequel'

module StringofFate
  # Models a platform
  class Hashtag < Sequel::Model
    many_to_one :account
    many_to_one :hashtag

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :giver_id, :owner_id, :hashtag_id

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'account_hashtag',
          attributes: {
            id:,
            giver_id:,
            owner_id:,
            hashtag_id:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
