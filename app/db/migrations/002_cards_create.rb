# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:cards) do
      primary_key :id
      foreign_key :owner_id, table: :accounts

      String :name_secure, null: false
      String :description_secure

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
