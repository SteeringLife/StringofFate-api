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

    def self.call(account:, card:, reciever_email:)
      invitee = Account.first(email: reciever_email)
      policy = GiveCardRequestPolicy.new(card, account, invitee)
      raise ForbiddenError unless policy.can_give_card_to_reciever?

      card.add_reciever(invitee)
      invitee
    end
  end
end
