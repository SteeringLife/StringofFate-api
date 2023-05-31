# frozen_string_literal: true

module StringofFate
  # Add a collaborator to another owner's existing card
  class GetCardQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that card'
      end
    end

    # Error for cannot find a card
    class NotFoundError < StandardError
      def message
        'We could not find that card'
      end
    end

    def self.call(auth:, card:)
      raise NotFoundError unless card

      policy = CardPolicy.new(auth[:account], card, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      card.full_details.merge(policies: policy.summary)
    end
  end
end
