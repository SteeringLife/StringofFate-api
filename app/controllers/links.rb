# frozen_string_literal: true

require 'roda'
require_relative './app'

module StringofFate
  # Web controller for String of Fate API
  class Api < Roda
    route('links') do |routing| # rubocop:disable Metrics/BlockLength
      @account_route = "#{@api_root}/links"

      routing.on String do |link_id|
        # GET api/v1/links/[link_id]
        routing.get do
          link = Link.first(id: link_id)
          link ? link.to_json : raise('Could not find link')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      routing.on 'links' do
        @link_route = "#{@api_root}/links/#{username}"
        # GET api/v1/links/
        routing.get do
          account = Account.first(username: @auth_account['username'])
          links = account.owned_links
          JSON.pretty_generate(data: links)
        rescue StandardError
          routing.halt(404, { message: 'Could not find links' }.to_json)
        end

        # POST api/v1/links/[platform_name]
        routing.post String do |platform_name|
          platform = Platform.first(name: platform_name)
          owner = Account.first(username: @auth_account['username'])
          new_data = JSON.parse(routing.body.read)

          new_link = Link.new(new_data, owner:, platform:)
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
