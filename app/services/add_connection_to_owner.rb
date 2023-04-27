# frozen_string_literal: true

module StringofFate
  # Add a connection to owner
  class AddConnectionToOwner
    def self.call(receiver_username:, sender_username:)
      receiver = Account.first(username: receiver_username)
      sender = Account.first(username: sender_username)
      sender.add_connection(receiver)
    end
  end
end
