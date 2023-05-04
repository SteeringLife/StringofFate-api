# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:links) do
      primary_key :id
      foreign_key :platform_id, table: :platforms
      foreign_key :owner_id, table: :accounts

      String :nickname_secure
      String :url_secure, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at

      unique [:owner_id, :url_secure]
    end
  end
end
