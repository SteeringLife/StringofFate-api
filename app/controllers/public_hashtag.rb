# rubocop:disable Metrics/BlockLength
# frozen_string_literal: true

require_relative './app'

module StringofFate
  # Web controller for StringofFate API
  class Api < Roda
    route('public_hashtags') do |routing|
      @link_route = "#{@api_root}/public_hashtags"

      routing.is do
        # GET api/v1/public_hashtags
        routing.get do
          all_public_hashtags = PublicHashtag.all
          all_public_hashtags.map(&:to_json)
        rescue StandardError => e
          puts "GET PUBLIC HASHTAGS ERROR: #{e.inspect}"
          routing.halt 403, { message: 'Could not find any public hashtags' }.to_json
        end

        # POST api/v1/public_hashtags
        routing.post do
          new_tag = CreatePublicHashtag.call(
            account: @current_account,
            card: @current_card,
            public_hashtag_data: JSON.parse(routing.body.read)
          )

          response.status = 201
          response['Location'] = "#{@link_route}/#{new_tag[:id]}"
          { message: 'Public hashtag created', public_hashtag: new_tag }.to_json
        rescue CreatePublicHashtag::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue CreatePublicHashtag::IllegalRequestError => e
          routing.halt 400, { message: e.message }.to_json
        rescue StandardError => e
          puts "CREATE PUBLIC HASHTAG ERROR: #{e.inspect}"
          Api.logger.error "Failed to create public hashtag: #{e.inspect}"
          routing.halt 500, { message: e.message }.to_json
        end
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
