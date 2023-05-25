# frozen_string_literal: true

require 'roda'
require_relative './app'

module StringofFate
  # Web controller for StringofFate API
  class Api < Roda
    route('platforms') do |routing| # rubocop:disable Metrics/BlockLength
      routing.on String do |platform_name|
        # GET api/v1/platforms/[platform_name]
        routing.get do
          platform = Platform.first(name: platform_name)
          platform ? platform.to_json : raise('Could not find platform')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

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
        new_platform = CreateNewPlatform.call(platform_data: new_data)
        raise 'Could not save platform' unless new_platform.save

        response.status = 201
        response['Location'] = "#{@api_root}/platforms/#{new_platform.name}"
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
