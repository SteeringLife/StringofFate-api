# frozen_string_literal: true

# Policy to determine if account can create a public hashtag
class PublicHashtagPolicy
  def initialize(public_hashtag_data)
    @public_hashtag_data = public_hashtag_data
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
    all_public_hashtags = StringofFate::PublicHashtag.all
    all_public_hashtags.each do |tag|
      return true if tag.content == @public_hashtag_data['content']
    end
    false
  end
end
