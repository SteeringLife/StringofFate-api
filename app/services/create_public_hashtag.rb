# frozen_string_literal: true

module StringofFate
  # Create a public hashtag to database
  class CreatePublicHashtag
    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create apublic hashtag'
      end
    end

    # Error for tag already exist
    class ForbiddenError < StandardError
      def message
        'Hashtag already exist'
      end
    end

    def self.call(public_hashtag_data:)
      policy = PublicHashtagPolicy.new(public_hashtag_data)
      raise ForbiddenError unless policy.can_create?

      create_public_hashtag(public_hashtag_data)
    end

    def self.create_public_hashtag(public_hashtag_data)
      new_hashtag = PublicHashtag.new(public_hashtag_data)
      raise IllegalRequestError unless new_hashtag.save
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
