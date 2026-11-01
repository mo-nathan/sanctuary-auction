# frozen_string_literal: true

require 'test_helper'

class HeartRankingTest < ActiveSupport::TestCase
  def setup
    @user = users(:user_no_bids)
    @ranking = HeartRanking.new(@user)
  end

  def raffle_items(count)
    Array.new(count) { |index| Item.create!(title: format('Raffle %02d', index), number: 1) }
  end

  def amounts(items)
    bids = @user.bids.reload.index_by(&:item_id)
    items.map { |item| bids[item.id]&.amount.to_i }
  end

  def save(items)
    @ranking.save(items.map { |item| item.id.to_s })
  end

  test 'ranked items sort by most hearts then title' do
    high = Item.create!(title: 'Z High', number: 1)
    tied_b = Item.create!(title: 'B Tied', number: 1)
    tied_a = Item.create!(title: 'A Tied', number: 1)
    [[high, 5], [tied_b, 2], [tied_a, 2]].each { |item, amount| @user.bids.create!(item:, amount:) }

    assert_equal([high, tied_a, tied_b], @ranking.ranked_items.to_a)
  end

  test 'unranked items are the other raffle items by title' do
    @user.bids.create!(item: items(:item_two), amount: 1)

    assert_equal(['Item Three', 'No Bid Item'], @ranking.unranked_items.map(&:title))
  end

  test 'items with zero hearts are unranked' do
    @user.bids.create!(item: items(:item_two), amount: 0)

    assert_empty(@ranking.ranked_items)
    assert_includes(@ranking.unranked_items, items(:item_two))
  end

  test 'unlimited and auction items are not offered' do
    auction = Item.create!(title: 'Auction', number: 1, auction: true)
    @user.bids.create!(item: auction, amount: 5)
    @user.bids.create!(item: items(:item_one), amount: 10)

    assert_empty(@ranking.ranked_items)
    assert_not_includes(@ranking.unranked_items, auction)
    assert_not_includes(@ranking.unranked_items, items(:item_one))
  end

  test 'save counts down from the top amount in the given order' do
    list = raffle_items(3).reverse
    save(list)

    assert_equal([30, 29, 28], amounts(list))
    assert_equal(413, @user.balance)
    assert_equal(list, @ranking.ranked_items.to_a)
  end

  test 'save gives one heart to every item past the countdown' do
    list = raffle_items(32)
    save(list)

    assert_equal([*1..30].reverse + [1, 1], amounts(list))
    assert_equal(33, @user.balance)
  end

  test 'save assigns nothing once the hearts run out' do
    list = raffle_items(67)
    save(list)

    assert_equal(65, @user.bids.count)
    assert_equal([1, 0, 0], amounts(list).last(3))
    assert_equal(0, @user.balance)
  end

  test 'save gives the last item whatever hearts are left' do
    @user.update!(balance: 40)
    list = raffle_items(3)
    save(list)

    assert_equal([30, 10, 0], amounts(list))
    assert_equal(0, @user.balance)
  end

  test 'save replaces raffle bids and returns their hearts' do
    user = users(:user_two)
    HeartRanking.new(user).save([items(:item_three).id.to_s])

    assert_equal(30, user.bids.sole.amount)
    assert_equal(items(:item_three), user.bids.sole.item)
    assert_equal(490, user.balance)
  end

  test 'save with no items removes raffle bids' do
    user = users(:user_two)
    HeartRanking.new(user).save([])

    assert_empty(user.bids)
    assert_equal(520, user.balance)
  end

  test 'save leaves unlimited and auction bids and their hearts alone' do
    user = users(:user_one)
    auction = Item.create!(title: 'Auction', number: 1, auction: true)
    auction_bid = user.bids.create!(item: auction, amount: 15)
    user.update!(balance: 475)

    HeartRanking.new(user).save([items(:item_two).id.to_s])

    assert_equal(10, bids(:bid_one).reload.amount)
    assert_equal(15, auction_bid.reload.amount)
    assert_equal(465, user.balance)
  end

  test 'save ignores duplicates, unrankable items, and unknown ids' do
    item = items(:item_two)
    @ranking.save([item.id.to_s, item.id.to_s, items(:item_one).id.to_s, '0'])

    assert_equal(30, @user.bids.sole.amount)
    assert_equal(item, @user.bids.sole.item)
    assert_equal(470, @user.balance)
  end
end
