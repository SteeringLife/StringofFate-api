# frozen_string_literal: true

module StringofFate
  # Create new link for owner
  class CreateNewPlatform
    def self.call(platform_data:)
      Platform.add_platform(platform_data)
    end
  end
end
