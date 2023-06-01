# frozen_string_literal: true

module StringofFate
  # Policy to determine if an account can view a particular card
  class CardPolicy
    def initialize(account, card)
      @account = account
      @card = card
    end

    def can_view?
      account_is_owner? || account_is_reciever?
    end

    # duplication is ok!
    def can_edit?
      account_is_owner?
    end

    def can_delete?
      account_is_owner?
    end

    def can_discard?
      account_is_reciever?
    end

    def can_add_links?
      account_is_owner?
    end

    def can_remove_links?
      account_is_owner?
    end

    def can_give_card_to_reciever?
      account_is_owner?
    end

    def can_give?
      !(account_is_owner? || account_is_reciever?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_discard: can_discard?,
        can_add_links: can_add_links?,
        can_remove_links: can_remove_links?,
        can_give_card_to_reciever: can_give_card_to_reciever?,
        can_give: can_give?
      }
    end

    private

    def account_is_owner?
      @card.owner == @account
    end

    def account_is_reciever?
      @card.recievers.include?(@account)
    end
  end
end
