# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Link Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:platforms].each do |platform_data|
      StringofFate::Platform.create(platform_data)
    end
  end

  it 'HAPPY: should be able to get list of all links' do
    plat = StringofFate::Platform.first
    DATA[:links].each do |link|
      plat.add_link(link)
    end

    get "api/v1/platforms/#{plat.id}/links"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single link' do
    link_data = DATA[:links][1]
    plat = StringofFate::Platform.first
    link = plat.add_link(link_data)

    get "/api/v1/platforms/#{plat.id}/links/#{link.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal link.id
    _(result['data']['attributes']['nickname']).must_equal link_data['nickname']
  end

  it 'SAD: should return error if unknown link requested' do
    plat = StringofFate::Platform.first
    get "/api/v1/platforms/#{plat.id}/links/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Links' do
    before do
      @plat = StringofFate::Platform.first
      @link_data = DATA[:links][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new links' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post "api/v1/platforms/#{@plat.id}/links",
           @link_data.to_json, req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      link = StringofFate::Link.first

      _(created['id']).must_equal link.id
      _(created['nickname']).must_equal @link_data['nickname']
      _(created['url']).must_equal @link_data['url']
    end

    it 'SECURITY: should not create links with mass assignment' do
      bad_data = @link_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/platforms/#{@plat.id}/links",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end