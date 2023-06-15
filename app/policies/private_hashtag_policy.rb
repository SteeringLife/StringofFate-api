# frozen_string_literal: true

# Policy to determine if account can create a public hashtag
class PrivateHashtagPolicy
  def initialize(account, card, private_hashtag_data)
    @account = account
    @card = card
    @private_hashtag_data = private_hashtag_data
  end

  def can_create?
    account_owns_card? || account_received_card? and !tag_alreay_exist_on_card?
  end

  def can_delete?
    account_owns_private_hashtag?
  end

  def summary
    {
      can_create: can_create?,
      can_delete: can_delete?,
    }
  end

  private

  def tag_alreay_exist_on_card?
    @card.private_hashtags.any? { |tag| tag.content == @private_hashtag_data['content'] }
  end

  def account_received_card?
    @card.receivers.include?(@account)
  end

  def account_owns_card?
    @account.id == @card.owner.id
  end

  def account_owns_private_hashtag?
    private_hashtag = PrivateHashtag.secure_find(content: @private_hashtag_data['content'])
    @account.id == @private_hashtag.owner.id
  rescue StandardError
    false
  end
end
