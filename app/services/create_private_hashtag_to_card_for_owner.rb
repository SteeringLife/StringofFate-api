# frozen_string_literal: true

module StringofFate
  # Service object to create a new card for an owner

  class CreatePrivateHashtagToCardForOwner
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create this tag'
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
      private_hashtag = PrivateHashtag.new(private_hashtag_data)

      policy = PrivateHashtagPolicy.new(owner, card, private_hashtag_data)

      raise ForbiddenError unless policy.can_create?
      add_tag(owner, card, private_hashtag)
    end

    def self.add_tag(owner, card, tag)
      tag.card = card
      owner.add_private_hashtag(tag)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
