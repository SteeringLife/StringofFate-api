# frozen_string_literal: true

# Policy to determine if account can view a card
class DocumentPolicy
  def initialize(account, document)
    @account = account
    @document = document
  end

  def can_view?
    account_owns_project? || account_collaborates_on_project?
  end

  def can_edit?
    account_owns_project? || account_collaborates_on_project?
  end

  def can_delete?
    account_owns_project? || account_collaborates_on_project?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def account_owns_project?
    @document.card.owner == @account
  end

  def account_collaborates_on_project?
    @document.card.recievers.include?(@account)
  end
end
