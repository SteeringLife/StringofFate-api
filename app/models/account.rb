# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module StringofFate
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_links, class: :'StringofFate::Link', key: :owner_id
    many_to_many :connections,
                 class: :'StringofFate::Account',
                 join_table: :connection,
                 left_key: :addresser_id, right_key: :requester_id

    plugin :association_dependencies,
           owned_links: :destroy,
           connections: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password, :realname, :showname

    plugin :timestamps, update_on_create: true

    def links
      owned_links
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = StringofFate::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          id:,
          username:,
          email:,
          realname:,
          showname:
        }, options
      )
    end
  end
end
