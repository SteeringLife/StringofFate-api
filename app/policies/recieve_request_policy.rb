# frozen_string_literal: true

module StringofFate
  # Policy to determine if an account can view a particular card
  class GiveCardRequestPolicy
    def initialize(card, giver_account, reciever_account)
      @card = card
      @giver_account = giver_account
      @reciever_account = reciever_account
      @giver = CardPolicy.new(giver_account, card)
      @reciever = CardPolicy.new(reciever_account, card)
    end

    def can_give_card_to_reciever?
      @giver.can_give_card_to_reciever?
    end
  end
end
