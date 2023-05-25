# frozen_string_literal: true

module StringofFate
  # Create new link for owner
  class CreateNewPlatform
    def self.call(platform_data:)
      Platform.new(platform_data)
    end
  end
end
