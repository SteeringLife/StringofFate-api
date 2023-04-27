# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(receiver_id: :accounts, sender_id: :accounts) do
      primary_key :id
      Int :status, null: false, default: 0
    end
  end
end
