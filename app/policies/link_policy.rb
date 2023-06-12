# frozen_string_literal: true

# Policy to determine if account can view a link
class LinkPolicy
  def initialize(account, link, auth_scope = nil)
    @account = account
    @link = link
    @auth_scope = auth_scope
  end

  def can_view?
    account_owns_card? || account_recieved_the_card?
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

  def can_read?
    @auth_scope ? @auth_scope.can_read?('links') : false
  end

  def can_write?
    @auth_scope ? @auth_scope.can_write?('links') : false
  end

  def account_owns_card?
    @link.card.owner == @account
  end

  def account_recieved_the_card?
    @link.card.recievers.include?(@account)
  end
end
