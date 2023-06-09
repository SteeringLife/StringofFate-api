# frozen_string_literal: true

# Policy to determine if account can view a hashtag
class AddPublicHashtagPolicy
  def initialize(account, card, public_hashtag, auth_scope = nil)
    @account = account
    @card = card
    @public_hashtag = public_hashtag
    @auth_scope = auth_scope
  end

  def can_add?
    account_owns_card? and !tag_already_exist_on_the_card?
  end

  def can_view?
    account_owns_card? || account_receive_this_card?
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

  def account_receive_this_card?
    @card.receivers.include?(@account)
  end

  def tag_already_exist_on_the_card?
    @card.public_hashtags.include?(@public_hashtag)
  end
end
