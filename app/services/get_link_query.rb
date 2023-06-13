# frozen_string_literal: true

module StringofFate
  # Add a collaborator to another owner's existing card
  class GetLinkQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that link'
      end
    end

    # Error for cannot find a card
    class NotFoundError < StandardError
      def message
        'We could not find that link'
      end
    end

    # Link for given requestor account
    def self.call(auth:, link:)
      raise NotFoundError unless link

      policy = LinkPolicy.new(auth[:account], link, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      link
    end
  end
end
