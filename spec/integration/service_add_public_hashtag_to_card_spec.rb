# rubocop:disable Metrics/BlockLength
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test adding public hashtag to card' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      StringofFate::Account.create(account_data)
    end

    @card_data = DATA[:cards].first

    @owner = StringofFate::Account.all[0]
    @public_hashtag = StringofFate::PublicHashtag.create(DATA[:public_hashtags][0])
    @owner_data = DATA[:accounts][0]
    auth = authorization(@owner_data)
    @card = StringofFate::CreateCardForOwner.call(
      auth:, card_data: @card_data
    )
  end

  it 'HAPPY: should be able to add public hashtag to card' do
    StringofFate::AddPublicHashtag.call(
      account: @owner,
      card: @card,
      public_hashtag_id: @public_hashtag.id
    )

    _(@card.public_hashtags.count).must_equal 1
    _(@card.public_hashtags.first).must_equal @public_hashtag
  end

  it 'BAD: should not add public hashtag to card if already exist' do
    StringofFate::AddPublicHashtag.call(
      account: @owner,
      card: @card,
      public_hashtag_id: @public_hashtag.id
    )
    _(proc {
      StringofFate::AddPublicHashtag.call(
        account: @owner,
        card: @card,
        public_hashtag_id: @public_hashtag.id
      )
    }).must_raise StringofFate::AddPublicHashtag::ForbiddenError
  end
end

# rubocop:enable Metrics/BlockLength
