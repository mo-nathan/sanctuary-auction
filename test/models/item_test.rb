# frozen_string_literal: true

require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test 'should not save item without title' do
    item = Item.new
    assert_not item.save, 'Saved the article without a title'
  end

  test 'buy-in item' do
    items(:item_one).item_type == :buy_in
  end

  test 'raffle item' do
    items(:item_two).item_type == :raffle
  end

  test 'auction item' do
    items(:item_no_bids).item_type == :auction
  end
end
