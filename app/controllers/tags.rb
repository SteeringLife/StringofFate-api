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
          puts @cards_viewlist
          run pry
          # view_cards = cards_viewlist.map { |card| GetCardQuery.call(auth: @auth, card:) }
          # cards = view_cards
          # JSON.pretty_generate(data: cards)
          cards_with_tag = @cards_viewlist.select do |card|
            card.public_hashtags.each{ |pub| pub.content.include?(@tag)} || card.user_private_hashtags(@auth_account).each{|priv| priv.content.include?(@tag)}
          end
          puts cards_with_tag

          cards = cards_with_tag.map { |card| GetCardQuery.call(auth: @auth, card:) }
          JSON.pretty_generate(data: cards)
          run pry
        rescue StandardError => e
          Api.logger.error "Unknown error: #{e.message}"
          run pry
          routing.halt 403, { message: 'Could not find any cards with the specified tag' }.to_json
        end
      end
    end
  end
end
