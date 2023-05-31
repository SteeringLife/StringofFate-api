# frozen_string_literal: true

module StringofFate
  # Add a public hashtag to another owner's existing card
  class AddPublicHashtag
    def self.call(account:, card:, public_hashtag_id:)
      public_hashtag = PublicHashtag.first(id: public_hashtag_id)
      policy = PublicHashtagPolicy.new(account, card)
      raise ForbiddenError unless policy.can_add?

      card.add_public_hashtag(public_hashtag)
      public_hashtag
    end
  end
end
