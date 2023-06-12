# frozen_string_literal: true

module StringofFate
  # Policy to determine if an account can view a particular card
  class CardPolicy
    def initialize(account, card, auth_scope = nil)
      @account = account
      @card = card
      @auth_scope = auth_scope
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

    def can_recieve?
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
        can_recieve: can_recieve?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('cards') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('cards') : false
    end

    def account_is_owner?
      @card.owner == @account
    end

    def account_is_reciever?
      @card.recievers.include?(@account)
    end
  end
end
