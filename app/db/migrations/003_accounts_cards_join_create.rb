# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(receiver_id: :accounts, card_id: :cards)
  end
end
