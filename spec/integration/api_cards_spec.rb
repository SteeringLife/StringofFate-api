# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Card Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = StringofFate::Account.create(@account_data)
    @wrong_account = StringofFate::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting cards' do
    describe 'Getting list of cards' do
      before do
        @account.add_owned_card(DATA[:cards][0])
        @account.add_owned_card(DATA[:cards][1])
      end

      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get 'api/v1/cards'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process without authorization' do
        get 'api/v1/cards'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single card' do
      card = @account.add_owned_card(DATA[:cards][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/cards/#{card.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal card.id
      _(result['attributes']['name']).must_equal card.name
      _(result['attributes']['description']).must_equal card.description
    end

    it 'SAD: should return error if unknown card requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/cards/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get card with wrong authorization' do
      card = @account.add_owned_card(DATA[:cards][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/cards/#{card.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
      @account.add_owned_card(DATA[:cards][0])
      @account.add_owned_card(DATA[:cards][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/cards/2%20or%20id%3E0'

      # deliberately not reporting detection -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Cards' do
    before do
      @card = DATA[:cards][0]
    end

    it 'HAPPY: should be able to create new cards' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/cards', @card.to_json

      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      card = StringofFate::Card.first

      _(created['id']).must_equal card.id
      _(created['name']).must_equal @card['name']
      _(created['description']).must_equal @card['description']
    end

    it 'SAD: should not create new card without authorization' do
      post 'api/v1/cards', @card.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create card with mass assignment' do
      bad_data = @card.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/cards', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
