# frozen_string_literal: true

module StringofFate
  # Service object to create new private hashtag to the card for the user.
  class CreatePrivateHashtagToCardForOwner
    # Error when user is not allowed to create a private_hashtag
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create this private_hashtag'
      end
    end

    # Mass assignment error
    class IllegalRequestError < StandardError
      def message
        'Illegal request'
      end
    end

    def self.call(auth:, card_id:, private_hashtag_data:)
      owner = auth[:account]
      card = Card.find(id: card_id)

      policy = PrivateHashtagPolicy.new(owner, card, private_hashtag_data)
      raise ForbiddenError unless policy.can_create?

      add_private_hashtag(owner, card, private_hashtag_data)
    end

    def self.add_private_hashtag(owner, card, private_hashtag_data)
      private_hashtag = PrivateHashtag.new(private_hashtag_data)
      private_hashtag.card = card
      owner.add_private_hashtag(private_hashtag)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
