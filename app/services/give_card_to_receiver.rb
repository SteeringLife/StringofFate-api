# frozen_string_literal: true

module StringofFate
  # Add a receiver to another owner's existing card
  class GiveCardToeceiver
    # Error for owner cannot be receiver
    class ForbiddenError < StandardError
      def message
        'Owner cannot give card to self'
      end
    end

    def self.call(auth:, card:, receiver_email:)
      receiver_account = Account.first(email: receiver_email)
      policy = GiveCardPolicy.new(card, auth[:account], receiver_account, auth[:scope])
      raise ForbiddenError unless policy.can_give_card_to_receiver?

      card.add_receiver(receiver_account)
      receiver_account
    end
  end
end
