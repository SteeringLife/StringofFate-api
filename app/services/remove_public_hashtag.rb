# frozen_string_literal: true

module StringofFate
  # Add a public hashtag to a card
  class RemovePublicHashtag
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that hashtag'
      end
    end

    def self.call(auth:, public_hashtag_id:, card_id:)
      card = Card.first(id: card_id)
      public_hashtag = PublicHashtag.first(id: public_hashtag_id)

      policy = PublicHashtagPolicy.new(auth[:account], card, auth[:scope])
      raise ForbiddenError unless policy.can_delete?

      card.remove_public_hashtag(public_hashtag)
      public_hashtag
    end
  end
end
