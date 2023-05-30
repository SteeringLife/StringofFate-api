# frozen_string_literal: true

module StringofFate
  # Service object to create a new card for an owner
  class CreateProjectForOwner
    def self.call(owner_id:, card_data:)
      Account.find(id: owner_id)
             .add_owned_card(card_data)
    end
  end
end
