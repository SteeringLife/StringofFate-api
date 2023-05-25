# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module StringofFate
  # Models a registered account
  class Card < Sequel::Model
    many_to_one :owner, class: :'StringofFate::Account'

    many_to_many :reciever,
                 class: :'StringofFate::Account',
                 join_table: :cards_recievers,
                 left_key: :card_id, right_key: :reciever_id

    one_to_many :links

    many_to_many :public_hashtags,
                 class: :'StringofFate::PublicHashtag',
                 join_table: :cards_public_hashtags,
                 left_key: :card_id, right_key: :public_hashtag_id

    one_to_many :private_hashtags

    plugin :association_dependencies,
           owned_links: :destroy,
           owned_public_hashtags: :nullify

    plugin :whitelist_security
    set_allowed_columns :name, :discrption

    plugin :timestamps, update_on_create: true

    def to_json(options = {})
      JSON(
        {
          type: 'card',
          attributes: {
            id:,
            name:,
            discrption:
          }
        }, options
      )
    end
  end
end
