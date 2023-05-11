# frozen_string_literal: true

require 'roda'
require_relative './app'

module StringofFate
  # Web controller for String of Fate API
  class Api < Roda
    route('links') do |routing| # rubocop:disable Metrics/BlockLength
      @account_route = "#{@api_root}/links"

      routing.on String do |username|
        routing.on 'links' do
          @link_route = "#{@api_root}/links/#{username}"
          # GET api/v1/links/[username]
          routing.get do
            output = { data: Account.first(id: username).owned_links }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt(404, { message: 'Could not find links' }.to_json)
          end

          # POST api/v1/links/[username]/[platform_name]
          routing.post String do |platform_name|
            new_data = JSON.parse(routing.body.read)
            platform = Platform.first(name: platform_name)
            owner = Account.first(id: username)

            new_link = Link.new(new_data)
            raise('Could not save link') unless new_link.save

            response.status = 201
            response['Location'] = "#{@account_route}/#{username}/links/#{platform}"
            { message: 'Account saved', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => e
            Api.logger.error 'Unknown error saving account'
            routing.halt 500, { message: e.message }.to_json
          end
        end
      end
    end
  end
end
