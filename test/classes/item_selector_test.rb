# frozen_string_literal: true

require 'test_helper'

class ItemSelectorTest < ActiveSupport::TestCase
  test 'should win bid when bid total is less' do
    selector = ItemSelector.new
    winner = bids(:bid_two)
    loser = bids(:bid_three)
    assert(selector.total_bids(winner.item) < selector.total_bids(loser.item))
    selector.consider(loser)
    selector.consider(winner)
    assert_equal(selector.sample, winner.item)
  end

  test 'might be either when bid totals are the same' do
    selector = ItemSelector.new
    loser = bids(:bid_one)
    winner_one = bids(:bid_three)
    winner_two = bids(:bid_four)
    selector.consider(loser)
    selector.consider(winner_one)
    selector.consider(winner_two)
    result = selector.sample
    assert_not_equal(loser, result)
    assert(result == winner_one.item || result == winner_two.item)
  end
end
