# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:links) do
      primary_key :id
      foreign_key :platform_id, table: :platforms
      foreign_key :card_id, table: :cards

      String :name_secure
      String :url_secure, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
