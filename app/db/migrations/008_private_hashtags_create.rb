# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:private_hashtags) do
      primary_key :id

      foreign_key :card_id, table: :cards, null: false
      foreign_key :owner_id, table: :accounts, null: false

      String :content_secure, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
