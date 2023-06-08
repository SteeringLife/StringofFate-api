# frozen_string_literal: true

module StringofFate
  # Add a public hashtag to owner's existing card
  class AddPublicHashtag
    # Error for requests with illegal attributes
    class AlreadyExistError < StandardError
      def message
        'Hashtag already exists'
      end
    end

    def self.call(account:, card:, public_hashtag_id:)
      public_hashtag = PublicHashtag.first(id: public_hashtag_id)
      policy = AddPublicHashtagPolicy.new(account, card, public_hashtag)
      raise AlreadyExistError unless policy.can_add?

      card.add_public_hashtag(public_hashtag)
      public_hashtag
    end
  end
end
