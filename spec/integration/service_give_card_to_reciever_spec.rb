# rubocop:disable Metrics/BlockLength
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test GiveCardToReciever service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      StringofFate::Account.create(account_data)
    end

    card_data = DATA[:cards].first
    @owner_data = DATA[:accounts][0]
    @owner = StringofFate::Account.all[0]
    @reciever = StringofFate::Account.all[1]
    auth = authorization(@owner_data)
    @card = StringofFate::CreateCardForOwner.call(
      auth:, card_data:
    )
  end

  it 'HAPPY: should be able to give a card to a reciever' do
    auth = authorization(@owner_data)

    StringofFate::GiveCardToReciever.call(
      auth:,
      card: @card,
      reciever_email: @reciever.email
    )

    _(@reciever.cards.count).must_equal 1
    _(@reciever.cards.first).must_equal @card
  end

  it 'BAD: should not give card to owner' do
    auth = StringofFate::AuthenticateAccount.call(
      username: @owner_data['username'],
      password: @owner_data['password']
    )

    _(proc {
      StringofFate::GiveCardToReciever.call(
        auth:,
        card: @card,
        reciever_email: @owner.email
      )
    }).must_raise StringofFate::GiveCardToReciever::ForbiddenError
  end
end

# rubocop:enable Metrics/BlockLength
