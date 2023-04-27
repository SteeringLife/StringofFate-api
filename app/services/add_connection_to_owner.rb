# frozen_string_literal: true

module StringofFate
  # Add a connection to owner
  class AddConnectionToOwner
    def self.call(addresser_username:, requester_username:)
      addresser = Account.first(username: addresser_username)
      requester = Account.first(username: requester_username)
      requester.add_connection(addresser)
    end
  end
end
