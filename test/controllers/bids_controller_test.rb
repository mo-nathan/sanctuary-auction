# frozen_string_literal: true

require 'test_helper'

class BidsControllerTest < ActionDispatch::IntegrationTest
  test 'create' do
    before = Bid.count
    post(item_bids_path(item_id: items(:one).id),
         params: { bid: { code: users(:one).code, amount: '100' } })
    assert_response :redirect
    follow_redirect!
    assert_equal(before + 1, Bid.count)
  end
end
