# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Platform Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all platforms' do
    StringofFate::Platform.create(DATA[:platforms][0]).save
    StringofFate::Platform.create(DATA[:platforms][1]).save

    get 'api/v1/platforms'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single platform' do
    existing_platform = DATA[:platforms][1]
    StringofFate::Platform.create(existing_platform).save
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

  it 'HAPPY: should be able to create new platforms' do
    existing_platform = DATA[:platforms][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/platforms', existing_platform.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    platform = StringofFate::Platform.first

    _(created['id']).must_equal platform.id
    _(created['name']).must_equal existing_platform['name']
    _(created['category']).must_equal existing_platform['category']
  end
end
