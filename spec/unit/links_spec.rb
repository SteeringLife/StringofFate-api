# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Link Handling' do
  before do
    wipe_database

    DATA[:platforms].each do |platform_data|
      StringofFate::Platform.create(platform_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    link_data = DATA[:links][1]
    plat = StringofFate::Platform.first
    new_link = plat.add_link(link_data)

    link = StringofFate::Link.find(id: new_link.id)
    _(link.nickname).must_equal link_data['nickname']
    _(link.url).must_equal link_data['url']
  end

  it 'SECURITY: should secure sensitive attributes' do
    link_data = DATA[:links][1]
    plat = StringofFate::Platform.first
    new_link = plat.add_link(link_data)
    stored_link = app.DB[:links].first

    _(stored_link[:nickname_secure]).wont_equal new_link.nickname
    _(stored_link[:url_secure]).wont_equal new_link.url
  end
end
