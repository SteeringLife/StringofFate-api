# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module StringofFate
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_links, class: :'StringofFate::Link', key: :owner_id
    one_to_many :connection_senders, class: :'StringofFate::Connection', key: :sender_id
    one_to_many :connection_receivers, class: :'StringofFate::Connection', key: :receiver_id

    plugin :association_dependencies,
           owned_links: :destroy,
           connection_senders: :nullify,
           connection_receivers: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password, :realname, :showname

    plugin :timestamps, update_on_create: true

    def links
      owned_links
    end

    def connections
      connection_senders + connection_receivers
    end

    def send_connections
      connection_receivers
    end

    def received_connection
      connection_senders
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = StringofFate::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          type: 'account',
          attributes: {
            username:,
            email:,
            realname:,
            showname:
          }
        }, options
      )
    end
  end
end
