# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:connections) do
      primary_key :id
      foreign_key :sender_id, table: :accounts
      foreign_key :reciever_id, table: :accounts
      Int :status, null: false, default: 0

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
