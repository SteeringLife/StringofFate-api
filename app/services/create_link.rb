# frozen_string_literal: true

module StringofFate
  # Add a collaborator to another owner's existing card
  class CreateLink
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more links'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a links with those attributes'
      end
    end

    def self.call(account:, card:, link_data:)
      policy = CardPolicy.new(account, card)
      raise ForbiddenError unless policy.can_add_links?

      add_link(card, link_data)
    end

    def self.add_link(card, link_data)
      card.add_link(link_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
