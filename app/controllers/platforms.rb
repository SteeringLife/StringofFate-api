# frozen_string_literal: true

require 'roda'
require_relative './app'

module StringofFate
  # Web controller for StringofFate API
  class Api < Roda
    route('platforms') do |routing|
      @platform_route = "#{@api_root}/platforms"

      routing.on @platform_route do
        # GET api/v1/platforms
        routing.get do
          output = { data: Platform.all }
          JSON.pretty_generate(output)
        rescue StandardError
          routing.halt 404, { message: 'Could not find platform' }.to_json
        end

        # POST api/v1/platforms
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_platform = StringofFate::CreateNewPlatform.call(platform_data: new_data)
          raise 'Could not save platform' unless new_platform.save

          response.status = 201
          response['Location'] = "#{@api_root}/platforms/#{new_platform_id}"
          { message: 'Platform saved', data: new_platform }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          Api.logger.error "UNKOWN ERROR: #{e.message}"
          routing.halt 500, { message: 'Unknown server error' }.to_json
        end
      end
    end
  end
end
