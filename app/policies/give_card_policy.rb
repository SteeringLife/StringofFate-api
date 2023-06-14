# frozen_string_literal: true

module StringofFate
  # Policy to determine if an account can view a particular card
  class GiveCardPolicy
    def initialize(card, giver_account, receiver_account, auth_scope = nil)
      @card = card
      @giver_account = giver_account
      @receiver_account = receiver_account
      @auth_scope = auth_scope
      @giver = CardPolicy.new(giver_account, card, auth_scope)
      @receiver = CardPolicy.new(receiver_account, card, auth_scope)
    end

    def can_give_card_to_receiver?
      can_write? &&
        (@giver.can_give_card_to_receiver? && @receiver.can_receive?)
    end

    def can_remove?
      no_you_cant
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('cards') : false
    end

    def target_is_receiver?
      @card.receivers.include?(@receiver_account)
    end

    def no_you_cant
      false
    end
  end
end
