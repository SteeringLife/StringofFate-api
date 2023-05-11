# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:hashtags) do
      primary_key :id
      String :content_secure, unique: true, null: false
    end
  end
end
