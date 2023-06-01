# frozen_string_literal: true

module StringofFate
  # Add a reciever to another owner's existing card
  class GiveCardToReciever
    # Error for owner cannot be reciever
    class ForbiddenError < StandardError
      def message
        'Owner cannot give card to self'
      end
    end

    def self.call(owner:, card:, reciever_email:)
      reciever_account = Account.first(email: reciever_email)
      policy = GiveCardPolicy.new(card, owner, reciever_account)
      raise ForbiddenError unless policy.can_give_card_to_reciever?

      card.add_reciever(reciever_account)
      reciever_account
    end
  end
end
