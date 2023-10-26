# frozen_string_literal: true

require 'test_helper'

class BidsControllerTest < ActionDispatch::IntegrationTest
  test 'create' do
    before = Bid.count
    post(item_bids_path(item_id: items(:item_one).id),
         params: { bid: { code: users(:user_two).code, amount: '100' } })
    assert_response :redirect
    assert_equal(before + 1, Bid.count)
  end

  test 'create fail over budget' do
    before = Bid.count
    user = users(:user_one)
    post(item_bids_path(item_id: items(:item_two).id),
         params: { bid: { code: user.code, amount: user.balance + 1 } })
    assert(1, flash.count)
    assert_response :redirect
    assert_equal(before, Bid.count)
  end

  test 'create bad code' do
    before = Bid.count
    post(item_bids_path(item_id: items(:item_one).id),
         params: { bid: { code: 'BAD', amount: '100' } })
    assert_response :redirect
    assert_equal(before, Bid.count)
  end

  test 'replace bid' do
    bid = bids(:bid_one)
    amount = bid.amount
    bid_count = Bid.count
    user = bid.user
    balance = user.balance
    post(item_bids_path(item_id: bid.item.id),
         params: { bid: { code: user.code, amount: (amount * 2).to_s } })
    assert_response :redirect
    assert_equal(bid_count, Bid.count)
    user.reload
    assert_equal(balance - amount, user.balance)
  end

  test 'replace overrun' do
    bid = bids(:bid_one)
    amount = bid.amount
    bid_count = Bid.count
    user = bid.user
    balance = user.balance
    post(item_bids_path(item_id: bid.item.id),
         params: { bid: { code: user.code, amount: "600" } })
    assert_response :redirect
    assert_equal(bid_count - 1, Bid.count)
    user.reload
    assert_equal(balance + amount, user.balance)
  end
end
