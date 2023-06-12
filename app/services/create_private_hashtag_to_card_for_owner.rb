# frozen_string_literal: true

module StringofFate
  # Service object to create a new card for an owner

  class CreatePrivateHashtagToCardForOwner
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create this private_hashtag'
      end
    end

    class IllegalRequestError < StandardError
      def message
        'Illegal request'
      end
    end

    def self.call(owner_id:, card_id:, private_hashtag_data:)
      owner = Account.find(id: owner_id)
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
