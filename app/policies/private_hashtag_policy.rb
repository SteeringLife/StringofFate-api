# frozen_string_literal: true

# Policy to determine if account can create a public hashtag
class PrivateHashtagPolicy
  def initialize(account, card, private_hashtag_data)
    @account = account
    @card = card
    @private_hashtag_data = private_hashtag_data
  end

  def can_create?
    account_owns_card? and !tag_alreay_exist_on_card?
  end

  def can_delete?
    account_owns_card?
  end

  def summary
    {
      can_create: can_create?,
      can_delete: can_delete?
    }
  end

  private

  def tag_alreay_exist_on_card?
    @card.private_hashtags.any? { |tag| tag.content == @private_hashtag_data['content'] }
  end

  def account_owns_card?
    @account.id == @card.owner.id
  end
end
