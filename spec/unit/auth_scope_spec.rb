# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AuthScope' do
  include Rack::Test::Methods

  it 'AUTH SCOPE: should validate default full scope' do
    scope = AuthScope.new
    _(scope.can_read?('*')).must_equal true
    _(scope.can_write?('*')).must_equal true
    _(scope.can_read?('link')).must_equal true
    _(scope.can_write?('link')).must_equal true
  end

  it 'AUTH SCOPE: should evalutate read-only scope' do
    scope = AuthScope.new(AuthScope::READ_ONLY)
    _(scope.can_read?('links')).must_equal true
    _(scope.can_read?('cards')).must_equal true
    _(scope.can_read?('private_hashtags')).must_equal true
    _(scope.can_read?('public_hashtags')).must_equal true
    _(scope.can_write?('links')).must_equal false
    _(scope.can_write?('cards')).must_equal false
    _(scope.can_write?('private_hashtags')).must_equal false
    _(scope.can_write?('public_hashtags')).must_equal false
  end

  it 'AUTH SCOPE: should validate single limited scope' do
    scope = AuthScope.new('links:read')
    _(scope.can_read?('*')).must_equal false
    _(scope.can_write?('*')).must_equal false
    _(scope.can_read?('links')).must_equal true
    _(scope.can_write?('links')).must_equal false
    _(scope.can_read?('private_hashtags')).must_equal false
    _(scope.can_write?('private_hashtags')).must_equal false
    _(scope.can_read?('public_hashtags')).must_equal false
    _(scope.can_write?('public_hashtags')).must_equal false
  end

  it 'AUTH SCOPE: should validate list of limited scopes' do
    scope = AuthScope.new('cards:read links:write')
    _(scope.can_read?('*')).must_equal false
    _(scope.can_write?('*')).must_equal false
    _(scope.can_read?('cards')).must_equal true
    _(scope.can_write?('cards')).must_equal false
    _(scope.can_read?('links')).must_equal false
    _(scope.can_write?('links')).must_equal true
    _(scope.can_read?('private_hashtags')).must_equal false
    _(scope.can_write?('private_hashtags')).must_equal false
    _(scope.can_read?('public_hashtags')).must_equal false
    _(scope.can_write?('public_hashtags')).must_equal false
  end
end
