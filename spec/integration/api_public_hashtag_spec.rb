# rubocop:disable Metrics/BlockLength
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test PublicHashtag Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = StringofFate::Account.create(@account_data)
    @wrong_account = StringofFate::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting list of all public hashtags' do
    before do
      @public_hashtag_data = DATA[:public_hashtags]
      @public_hashtag_data.each do |public_hashtag_data|
        StringofFate::PublicHashtag.create(public_hashtag_data)
      end
    end

    it 'HAPPY: should be able to get list of all public hashtags for authorized account' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/public_hashtags'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'BAD: should not process without authorization' do
      get 'api/v1/public_hashtags'
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['data']).must_be_nil
    end
  end

  describe 'Creating Public hashtags' do
    before do
      @public_hashtag_data = DATA[:public_hashtags][0]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/public_hashtags', @public_hashtag_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      public_hashtag = StringofFate::PublicHashtag.first

      _(created['id']).must_equal public_hashtag.id
      _(created['content']).must_equal @public_hashtag_data['content']
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post 'api/v1/public_hashtags', @public_hashtag_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @public_hashtag_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/public_hashtags', bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end

# rubocop:enable Metrics/BlockLength
