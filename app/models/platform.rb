# frozen_string_literal: true

require 'json'
require 'sequel'

module StringofFate
  # Models a platform
  class Platform < Sequel::Model
    one_to_many :links
    plugin :association_dependencies, links: :destroy

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :category

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'platform',
            attributes: {
              id:,
              name:,
              category:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
