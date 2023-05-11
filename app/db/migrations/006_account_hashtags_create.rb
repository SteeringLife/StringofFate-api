# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:account_hashtags) do
      primary_key :id
      foreign_key :giver_id, :accounts
      foreign_key :hashtag_id, :hashtags
      foreign_key :owner_id, :accounts
      # Integer :is_public, null: false (0:private 1:accept 2:sent_pending)
    end
  end
end
