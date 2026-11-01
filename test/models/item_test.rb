# frozen_string_literal: true

require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test 'should not save item without title' do
    item = Item.new
    assert_not item.save, 'Saved the article without a title'
  end

  test 'raffle item' do
    assert_equal(items(:item_two).item_type, 'Raffle')
  end

  test 'replaces an imgur page link when creating an item' do
    item = Item.create!(title: 'Imgur', number: 1, image_url: 'https://imgur.com/hkiJR5W')
    assert_equal('https://i.imgur.com/hkiJR5W.jpeg', item.image_url)
  end

  test 'replaces an imgur page link when editing an item' do
    item = items(:item_two)
    item.update!(image_url: 'https://imgur.com/hkiJR5W')
    assert_equal('https://i.imgur.com/hkiJR5W.jpeg', item.image_url)
  end

  test 'skips the lookup when the image URL has not changed' do
    item = items(:item_two)
    ImageUrlResolver.expects(:resolve).never
    item.update!(title: 'New title')
  end

  test 'auction item' do
    assert_equal(items(:item_no_bids).item_type, 'Auction')
  end
end
