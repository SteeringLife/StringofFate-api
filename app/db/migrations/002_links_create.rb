# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:links) do
      primary_key :id
      foreign_key :platform_id, table: :platforms

      String :nickname
      String :url, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
