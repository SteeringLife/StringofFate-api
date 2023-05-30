# frozen_string_literal: true

module StringofFate
  # Add a reciever to another owner's existing card
  class GiveCardToReciever
    # Error for owner cannot be reciever
    class OwnerNotRecieverError < StandardError
      def message = 'Owner cannot give card to self'
    end

    def self.call(email:, card_id:)
      reciever = Account.first(email:)
      card = Card.first(id: card_id)
      raise(OwnerNotRecieverError) if card.owner.id == reciever.id

      card.add_reciever(reciever)
    end
  end
end
