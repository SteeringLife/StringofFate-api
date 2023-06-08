# frozen_string_literal: true

# Policy to determine if account can view a hashtag
class PublicHashtagPolicy
  def initialize(account, public_hashtag)
    @account = account
    @public_hashtag = public_hashtag
  end

  def can_create?
    !tag_alreay_exist?
  end

  def summary
    {
      can_create: can_create?
    }
  end

  private

  def tag_alreay_exist?
    StringofFate::PublicHashtag.first(content: @public_hashtag.content)
  end
end
