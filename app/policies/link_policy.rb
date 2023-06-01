# frozen_string_literal: true

# Policy to determine if account can view a link
class LinkPolicy
  def initialize(account, link)
    @account = account
    @link = link
  end

  def can_view?
    account_owns_link? || account_recieved_the_card?
  end

  def can_edit?
    account_owns_link?
  end

  def can_delete?
    account_owns_link?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def account_owns_link?
    @link.card.owner == @account
  end

  def account_recieved_the_card?
    @link.card.recievers.include?(@account)
  end
end
