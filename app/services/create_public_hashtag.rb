# frozen_string_literal: true

module StringofFate
  # Add a collaborator to another owner's existing card
  class CreatePublicHashtag
    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create apublic hashtag'
      end
    end

    # Error for not authorized requests
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create a public hashtag'
      end
    end

    def self.call(account:, card:, hashtag_data:)
      policy = PublicHashtagPolicy.new(account, card, hashtag_data)
      raise ForbiddenError unless policy.can_create?

      create_public_hashtag(hashtag_data)
    end

    def self.create_public_hashtag(hashtag_data)
      new_hashtag = PublicHashtag.new(hashtag_data)
      raise IllegalRequestError unless new_hashtag.save
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
