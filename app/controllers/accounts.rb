# frozen_string_literal: true

require 'roda'
require_relative './app'

module StringofFate
  # Web controller for String of Fate API
  class Api < Roda
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on String do |username|
        # GET api/v1/accounts/[username]
        routing.get do
          account = Account.first(username:)
          account ? account.to_json : raise('Account not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # POST api/v1/accounts
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_acct = Account.new(new_data)
        raise 'Could not save account' unless new_acct.save

        response.status = 201
        response['Location'] = "#{@api_root}/accounts/#{new_acct.username}"
        { message: 'Account saved', data: new_acct }.to_json
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
