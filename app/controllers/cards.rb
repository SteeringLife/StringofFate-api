# frozen_string_literal: true

require 'roda'
require_relative './app'

module Credence
  # Web controller for Credence API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('cards') do |routing|
      @card_route = "#{@api_root}/cards"

      routing.on String do |card_id|
        routing.on 'links' do
          @doc_route = "#{@api_root}/cards/#{card_id}/links"
          # GET api/v1/cards/[card_id]/links/[link_id] - get details of a link
          routing.get String do |link_id|
            doc = Link.where(card_id:, id: link_id).first
            doc ? doc.to_json : raise('Link not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # GET api/v1/cards/[card_id]/links - get all links of a card
          routing.get do
            output = { data: Card.first(id: card_id).links }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt(404, { message: 'Could not find links' }.to_json)
          end

          # POST api/v1/cards/[card_id]/links - create a new link for a card
          routing.post do
            new_data = JSON.parse(routing.body.read)

            new_doc = CreateLinkForCard.call(
              card_id: card_id, document_data: new_data
            )

            response.status = 201
            response['Location'] = "#{@doc_route}/#{new_doc.id}"
            { message: 'Link saved', data: new_doc }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.warn "MASS-ASSIGNMENT: #{e.message}"
            routing.halt 500, { message: 'Error creating document' }.to_json
          end
        end

        # GET api/v1/cards/[card_id]
        routing.get do
          proj = Card.first(id: card_id)
          proj ? proj.to_json : raise('Card not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET api/v1/cards/
      routing.get do
        account = Account.first(username: @auth_account['username'])
        run pry
        cards = account.cards
        JSON.pretty_generate(data: cards)
      rescue StandardError
        routing.halt 403, { message: 'Could not find any cards' }.to_json
      end

      # POST api/v1/cards
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_proj = Card.new(new_data)
        raise('Could not save project') unless new_proj.save

        response.status = 201
        response['Location'] = "#{@card_route}/#{new_proj.id}"
        { message: 'Card saved', data: new_proj }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue StandardError => e
        Api.logger.error "UNKOWN ERROR: #{e.message}"
        routing.halt 500, { message: 'Unknown server error' }.to_json
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
