# frozen_string_literal: true

module StringofFate
  # Create new link for owner
  class CreateLinkForOwner
    def self.call(owner_id:, link_data:)
      Account.first(id: owner_id).add_link(link_data)
    end
  end
end
