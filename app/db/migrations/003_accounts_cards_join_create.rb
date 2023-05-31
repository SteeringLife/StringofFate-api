# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(reciever_id: :accounts, card_id: :cards)
  end
end
