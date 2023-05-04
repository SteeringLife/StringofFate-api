# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table({ receiver_id: :accounts, sender_id: :accounts }, name: :connections) do
      Int :status, null: false, default: 0  # 0: request send , 1: approve, 2 banned

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
