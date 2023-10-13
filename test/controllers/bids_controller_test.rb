# frozen_string_literal: true

require 'test_helper'

class BidsControllerTest < ActionDispatch::IntegrationTest
  test 'create' do
    before = Bid.count
    post(item_bids_path(item_id: items(:one).id),
         params: { bid: { code: users(:one).code, amount: '100' } })
    assert_response :redirect
    assert_equal(before + 1, Bid.count)
  end

  test 'create fail over budget' do
    before = Bid.count
    user = users(:one)
    post(item_bids_path(item_id: items(:one).id),
         params: { bid: { code: user.code, amount: user.balance + 1 } })
    assert(1, flash.count)
    assert_response :redirect
    assert_equal(before, Bid.count)
  end
end
