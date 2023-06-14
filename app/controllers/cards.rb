# rubocop:disable Metrics/BlockLength, Metrics/ClassLength
# frozen_string_literal: true

require_relative './app'

module StringofFate
  # Web controller for StringofFate API
  class Api < Roda
    route('cards') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @card_route = "#{@api_root}/cards"
      routing.on String do |card_id|
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
              link_data: JSON.parse(routing.body.read)
            )

            response.status = 201
            response['Location'] = "#{@link_route}/#{new_link.id}"
            { message: 'Link saved', data: new_link }.to_json
          rescue CreateLink::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateLink::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            puts "CREATE LINK ERROR: #{e.inspect}"
            Api.logger.warn "Could not create link: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('receivers') do
          # PUT api/v1/cards/[card_id]/receivers
          routing.put do
            req_data = JSON.parse(routing.body.read)

            receiver = GiveCardToReceiver.call(
              auth: @auth,
              card: @req_card,
              receiver_email: req_data['email']
            )

            { data: receiver }.to_json
          rescue GiveCardToReceiver::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('public_hashtags') do # rubocop:disable Metrics/BlockLength
          # PUT api/v1/cards/[card_id]/public_hashtags
          routing.put do
            req_data = JSON.parse(routing.body.read)

            public_hashtag = AddPublicHashtag.call(
              auth: @auth,
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
              auth: @auth,
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

        routing.on('private_hashtags') do
          # POST api/v1/cards/[card_id]/private_hashtags
          @private_hashtag_route = "#{@card_route}/#{card_id}/private_hashtags"
          routing.post do
            created = CreatePrivateHashtagToCardForOwner.call(
              auth: @auth,
              card_id: @req_card.id,
              private_hashtag_data: JSON.parse(routing.body.read)
            )

            response.status = 201
            response['Location'] = "#{@private_hashtag_route}/#{created.id}"
            { message: 'Private Hashtag saved', data: created }.to_json
          rescue CreatePrivateHashtagToCardForOwner::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreatePrivateHashtagToCardForOwner::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            puts "CREATE PRIVATE HASHTAG ERROR: #{e.inspect}"
            Api.logger.warn "Could not create private hashtag: #{e.message}"
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
          new_card = @auth_account.add_owned_card(new_data)

          response.status = 201
          response['Location'] = "#{@card_route}/#{new_card.id}"
          { message: 'Card saved', data: new_card }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue StandardError => e
          Api.logger.error "Unknown error: #{e.message}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength, Metrics/ClassLength
