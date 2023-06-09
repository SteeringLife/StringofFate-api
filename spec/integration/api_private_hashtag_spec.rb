# rubocop:disable Metrics/BlockLength
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test PrivateHashtag Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = StringofFate::Account.create(@account_data)
    @account.add_owned_card(DATA[:cards][0])
    @wrong_account = StringofFate::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Creating Private hashtags on card for owner' do
    before do
      @card = @account.cards.first
      @private_hashtag_data = DATA[:private_hashtags][0]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/cards/#{@card.id}/private_hashtags", @private_hashtag_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      private_hashtag = StringofFate::PrivateHashtag.first

      _(created['id']).must_equal private_hashtag.id
      _(created['content']).must_equal @private_hashtag_data['content']
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/cards/#{@card.id}/private_hashtags", @private_hashtag_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @private_hashtag_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/cards/#{@card.id}/private_hashtags", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end

# rubocop:enable Metrics/BlockLength
