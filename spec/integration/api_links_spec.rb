# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Links Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting links' do
    describe 'Getting list of links' do
      before do
        @account_data = DATA[:accounts][0]
        account = StringofFate::Account.create(@account_data)
        account.add_owned_link(DATA[:links][0])
        account.add_owned_link(DATA[:links][1])
      end

      it 'HAPPY: should get list for authorized account' do
        auth = StringofFate::AuthenticateAccount.call(
          username: @account_data['username'],
          password: @account_data['password']
        )

        header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
        get 'api/v1/links'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/links'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single link' do
      existing_link = DATA[:links][1]
      StringofFate::Link.create(existing_link)
      id = StringofFate::Link.first.id

      get "/api/v1/links/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['attributes']['id']).must_equal id
      _(result['attributes']['name']).must_equal existing_link['name']
      _(result['attributes']['url']).must_equal existing_link['url']
    end

    it 'SAD: should return error if unknown link requested' do
      get '/api/v1/links/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      StringofFate::Link.create(name: 'New Link')
      StringofFate::Link.create(name: 'Newer Link')
      get 'api/v1/links/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New links' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @link_data = DATA[:links][1]
      StringofFate::Platform.create(DATA[:platforms][0])
    end

    it 'HAPPY: should be able to create new links' do
      post 'api/v1/links', @link_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      link = StringofFate::Link.first

      _(created['id']).must_equal link.id
      _(created['name']).must_equal @link_data['name']
      _(created['url']).must_equal @link_data['url']
    end

    it 'SECURITY: should not create link with mass assignment' do
      bad_data = @link_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/links', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
