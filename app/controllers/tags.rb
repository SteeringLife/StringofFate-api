# frozen_string_literal: true

require_relative './app'

module StringofFate
  # Web controller for StringofFate API
  class Api < Roda
    route('tags') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @tag_route = "#{@api_root}/tags"

      # GET api/v1/tags/[tag_content]
      routing.on String do |tag_content|
        @tag = tag_content.to_s
        routing.get do
          puts "GETTING CARDS WITH TAG #{@tag}"
          @cards_viewlist = CardPolicy::AccountScope.new(@auth_account).viewable

          # view_cards = cards_viewlist.map { |card| GetCardQuery.call(auth: @auth, card:) }
          # cards = view_cards
          # JSON.pretty_generate(data: cards)
          cards_with_tag = @cards_viewlist.select do |card|
            card.public_hashtags.any? { |pub| pub.content.include?(@tag) } || card.user_private_hashtags(@auth_account).any? { |priv| priv.content.include?(@tag) }
          end
          puts cards_with_tag
          tag_cards = cards_with_tag.map { |card| GetCardQuery.call(auth: @auth, card:) }
          puts tag_cards
          JSON.pretty_generate(data: tag_cards)
        rescue StandardError => e
          Api.logger.error "Unknown error: #{e.message}"
          routing.halt 403, { message: 'Could not find any cards with the specified tag' }.to_json
        end
      end
    end
  end
end
