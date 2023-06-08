# frozen_string_literal: true

# Policy to determine if account can view a hashtag
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
    puts StringofFate::PublicHashtag.all
    #(content: @public_hashtag_data['content'])
  end
end
