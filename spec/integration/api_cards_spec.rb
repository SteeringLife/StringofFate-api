# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Link Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:cards].each do |card_data|
      StringofFate::Card.create(card_data)
    end
  end

  it 'HAPPY: should be able to get list of all links' do
    card = StringofFate::Card.first
    DATA[:links].each do |link|
      card.add_link(link)
    end

    get "api/v1/cards/#{card.id}/links"
    _(last_response.status).must_equal 200

    result = JSON.parse(last_response.body)['data']
    _(result.count).must_equal 4
    result.each do |link|
      _(link['type']).must_equal 'link'
    end
  end

  it 'HAPPY: should be able to get details of a single link' do
    link_data = DATA[:links][1]
    card = StringofFate::Card.first
    link = card.add_link(link_data)

    get "/api/v1/cards/#{card.id}/links/#{link.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['attributes']['id']).must_equal link.id
    _(result['attributes']['filename']).must_equal link_data['filename']
  end

  it 'SAD: should return error if unknown link requested' do
    card = StringofFate::Card.first
    get "/api/v1/cards/#{card.id}/links/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Links' do
    before do
      @card = StringofFate::Card.first
      @link_data = DATA[:links][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new links' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post "api/v1/cards/#{@card.id}/links",
           @link_data.to_json, req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      link = StringofFate::Link.first

      _(created['id']).must_equal link.id
      _(created['filename']).must_equal @link_data['filename']
      _(created['description']).must_equal @link_data['description']
    end

    it 'SECURITY: should not create links with mass assignment' do
      bad_data = @link_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/cards/#{@card.id}/links",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
