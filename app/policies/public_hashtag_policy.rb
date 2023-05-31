# frozen_string_literal: true

# Policy to determine if account can view a hashtag
class PublicHashtagPolicy
  def initialize(account, card)
    @account = account
    @card = card
  end

  def can_add?
    account_owns_card?
  end

  def can_view?
    account_owns_card? || account_recieve_this_card?
  end

  def can_delete?
    account_owns_card?
  end

  def summary
    {
      can_add: can_add?,
      can_view: can_view?,
      can_delete: can_delete?
    }
  end

  private

  def account_owns_card?
    @card.owner == @account
  end

  def account_recieve_this_card?
    @card.recievers.include?(@account)
  end
end
