# frozen_string_literal: true

require_relative './app'

module StringofFate
  # Web controller for StringofFate API
  class Api < Roda
    route('cards') do |routing| # rubocop:disable Metrics/BlockLength
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @card_route = "#{@api_root}/cards"
      routing.on String do |card_id| # rubocop:disable Metrics/BlockLength
        @req_card = Card.first(id: card_id)

        # GET api/v1/cards/[ID]
        routing.get do
          card = GetCardQuery.call(auth: @auth, card: @req_card)

          { data: card }.to_json
        rescue GetCardQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetCardQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND CARD ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        routing.on('links') do
          # POST api/v1/cards/[card_id]/links
          routing.post do
            new_link = CreateLink.call(
              auth: @auth,
              card: @req_card,
              document_data: JSON.parse(routing.body.read)
            )

            response.status = 201
            response['Location'] = "#{@link_route}/#{new_link.id}"
            { message: 'Document saved', data: new_link }.to_json
          rescue CreateLink::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateLink::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            Api.logger.warn "Could not create document: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('public_hashtags') do # rubocop:disable Metrics/BlockLength
          # PUT api/v1/cards/[card_id]/public_hashtags
          routing.put do
            req_data = JSON.parse(routing.body.read)

            public_hashtag = AddPublicHashtag.call(
              account: @auth_account,
              card: @req_card,
              public_hashtag_id: req_data['id']
            )

            { data: public_hashtag }.to_json
          rescue AddPublicHashtag::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/cards/[card_id]/public_hashtags
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            public_hashtag = RemovePublicHashtag.call(
              account: @auth_account,
              public_hashtag_id: req_data['id'],
              card_id:
            )

            { message: "#{public_hashtag.content} removed from card",
              data: public_hashtag }.to_json
          rescue RemovePublicHashtag::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('recievers') do
          # PUT api/v1/cards/[card_id]/recievers
          routing.put do
            req_data = JSON.parse(routing.body.read)

            reciever = GiveCardToReciever.call(
              auth: @auth,
              card: @req_card,
              reciever_email: req_data['email']
            )

            { data: reciever }.to_json
          rescue GiveCardToReciever::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      routing.is do
        # GET api/v1/cards
        routing.get do
          cards = CardPolicy::AccountScope.new(@auth_account).viewable

          JSON.pretty_generate(data: cards)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any cards' }.to_json
        end

        # POST api/v1/cards
        routing.post do
          new_data = JSON.parse(routing.body.read)

          new_card = CreateCardForOwner.call(
            auth: @auth, card_data: new_data
          )

          response.status = 201
          response['Location'] = "#{@card_route}/#{new_card.id}"
          { message: 'Card saved', data: new_card }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue CreateCardForOwner::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          Api.logger.error "Unknown error: #{e.message}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
