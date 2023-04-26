# frozen_string_literal: true

module StringofFate
  # Create new link for a platform
  class CreateLinkForPlatform
    def self.call(platform_id:, link_data:)
      Platform.first(id: platform_id).add_link(link_data)
    end
  end
end
  