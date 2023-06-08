# frozen_string_literal: true

# Policy to determine if account can view a hashtag
class AddPublicHashtagPolicy
  def initialize(account, card, public_hashtag)
    @account = account
    @card = card
    @public_hashtag = public_hashtag
  end

  def can_add?
    account_owns_card? || !tag_already_exist_on_the_card?
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

  def tag_already_exist_on_the_card?
    @card.public_hashtags.include?(@public_hashtag)
  end
end
