# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:public_hashtags) do
      primary_key :id

      String :content_secure, unique: true, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
