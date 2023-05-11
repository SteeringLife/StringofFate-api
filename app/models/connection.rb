# rubocop:disable Lint/RedundantCopDisableDirective
# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module StringofFate
  # Models a registered account
  class Connection < Sequel::Model
    many_to_one :sender, class: :'StringofFate::Account'
    many_to_one :reciever, class: :'StringofFate::Account'

    plugin :whitelist_security
    set_allowed_columns :status

    plugin :timestamps, update_on_create: true

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          type: 'account',
          attributes: {
            id:,
            status:
          },
          included: {
            sender:,
            reciever:
          }
        }, options
      )
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective
