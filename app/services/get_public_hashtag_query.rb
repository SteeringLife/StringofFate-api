# frozen_string_literal: true

module StringofFate
  # Get a public hashtag for a particular owner
  class GetPublicHashtagQuery
    # Error for cannot find a public_hashtag
    class NotFoundError < StandardError
      def message
        'We could not find that public hashtag'
      end
    end

    def self.call(public_hashtag:)
      raise NotFoundError unless public_hashtag

      policy = CreatePublicHashtagPolicy.new(public_hashtag:)

      public_hashtag.full_details.merge(policies: policy.summary)
    end
  end
end
