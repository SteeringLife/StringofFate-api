# frozen_string_literal: true

# Policy to determine if account can view a card
class LinkPolicy
  def initialize(account, link)
    @account = account
    @link = link
  end

  def can_view?
    account_owns_card? || account_recieves_card?
  end

  def can_edit?
    account_owns_card?
  end

  def can_delete?
    account_owns_card?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def account_owns_card?
    @link.card.owner == @account
  end

  def account_recieves_card?
    @link.card.recievers.include?(@account)
  end
end
