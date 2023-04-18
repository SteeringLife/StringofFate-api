# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Platform Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting platforms' do
    it 'HAPPY: should be able to get list of all platforms' do
      StringofFate::Platform.create(DATA[:platforms][0])
      StringofFate::Platform.create(DATA[:platforms][1])

      get 'api/v1/platforms'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single platform' do
      existing_platform = DATA[:platforms][1]
      StringofFate::Platform.create(existing_platform)
      id = StringofFate::Platform.first.id

      get "/api/v1/platforms/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal id
      _(result['data']['attributes']['name']).must_equal existing_platform['name']
    end

    it 'SAD: should return error if unknown platform requested' do
      get '/api/v1/platforms/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating New Platforms' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @platform_data = DATA[:platforms][1]
    end

    it 'HAPPY: should be able to create new platforms' do
      post 'api/v1/platforms', @platform_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      plat = StringofFate::Platform.first

      _(created['id']).must_equal plat.id
      _(created['name']).must_equal @platform_data['name']
      _(created['category']).must_equal @platform_data['category']
    end

    it 'SECURITY: should not create platform with mass assignment' do
      bad_data = @platform_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/platforms', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end