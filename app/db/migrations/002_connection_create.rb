# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(addresser: :accounts, requester: :accounts) do
      primary_key :id
    end
  end
end
