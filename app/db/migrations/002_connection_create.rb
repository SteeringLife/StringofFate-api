# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(addresser: :accounts, requester: :accounts)
  end
end