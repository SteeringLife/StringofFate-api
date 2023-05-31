# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(card_id: :cards, public_hashtag_id: :public_hashtags)
  end
end
