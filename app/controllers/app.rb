# frozen_string_literal: true

require 'roda'
require 'json'

module StringofFate
  # Web controller for StringofFate API
  class Api < Roda
    plugin :halt

    # rubocop:disable Metrics/BlockLength
    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'StringofFate up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'accounts' do
          routing.on String do |username|
            routing.on 'links' do
              @link_root = "#{@api_root}/accounts/#{username}/links"
              # GET api/v1/accounts/[username]/links/[link_id]
              routing.get String do |link_id|
                link = Link.where(username:, id: link_id).first
                link ? link.to_json : raise('Link not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/accounts/[username]/links
              routing.get do
                output = { data: Account.first(username:).links }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find link'
              end

              # POST api/v1/accounts/[username]/links
              routing.post do
                new_data = JSON.parse(routing.body.read)
                acct = Account.first(id: username)
                new_link = acct.add_link(new_data)
                raise 'Could not save link' unless new_link

                response.status = 201
                response['Location'] = "#{@link_root}/#{new_link_id}"
                { message: 'Link saved', data: new_link }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                routing.halt 500, { message: e.message }.to_json
              end
            end

            # GET api/v1/accounts/[username]
            routing.get do
              acct = Account.first(username:)
              acct ? acct.to_json : raise('Account not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/accounts
          routing.get do
            output = { data: Account.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find account' }.to_json
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
      # rubocop:enable Metrics/BlockLength
    end
  end
end
