# frozen_string_literal: true

require 'rack/test'
require_relative '../spec_helper'

USRINFO = YAML.safe_load File.read('app/db/seeds/userinfo_seeds.yml')

describe 'Test StringofFate Web API' do
  include Rack::Test::Methods

  before do
    # Wipe database before each test
    Dir.glob("#{StringofFate::STORE_DIR}/*.txt").each { |filename| FileUtils.rm(filename) }
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'Handle userinfos' do
    it 'HAPPY: should be able to get list of all userinfos' do
      StringofFate::Userinfo.new(USRINFO[0]).save
      StringofFate::Userinfo.new(USRINFO[1]).save

      get 'api/v1/userinfos'
      result = JSON.parse last_response.body
      _(result['userinfo_ids'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single userinfo' do
      StringofFate::Userinfo.new(USRINFO[1]).save
      id = Dir.glob("#{StringofFate::STORE_DIR}/*.txt").first.split(%r{[/.]})[3]

      get "/api/v1/userinfos/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    it 'SAD: should return error if unknown userinfo requested' do
      get '/api/v1/userinfos/foobar'

      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new userinfos' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/userinfos', USRINFO[1].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end
end