# frozen_string_literal: true

module StringofFate
  # Service object to create a new card for an owner
  class CreateCardForOwner
    # Error for not allowed to create cards
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create cards'
      end
    end

    def self.call(auth:, card_data:)
      raise ForbiddenError unless auth[:scope].can_write?('cards')

      auth[:account].add_owned_card(card_data)
    end
  end
end
