# frozen_string_literal: true

module StringofFate
  # Add a public hashtag to owner's existing card
  class AddPublicHashtag
    # Error for requests with illegal attributes
    class ForbiddenError < StandardError
      def message
        'Should not add public hashtag'
      end
    end

    def self.call(account:, card:, public_hashtag_content:)
      public_hashtag = PublicHashtag.secure_find(content: public_hashtag_content)
      policy = AddPublicHashtagPolicy.new(account, card, public_hashtag)
      raise ForbiddenError unless policy.can_add?

      card.add_public_hashtag(public_hashtag)
      public_hashtag
    end
  end
end
