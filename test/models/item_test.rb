# frozen_string_literal: true

require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test 'should not save item without title' do
    item = Item.new
    assert_not item.save, 'Saved the article without a title'
  end

  test 'buy-in item' do
    assert_equal(items(:item_one).item_type, 'Buy-In')
  end

  test 'raffle item' do
    assert_equal(items(:item_two).item_type, 'Raffle')
  end

  test 'auction item' do
    assert_equal(items(:item_no_bids).item_type, 'Auction')
  end
end
