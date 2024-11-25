# frozen_string_literal: true

require 'test_helper'

class ItemAllocatorTest < ActiveSupport::TestCase
  test 'should successfully run report' do
    assert_equal(ItemAllocator.new.report.count, Item.joins(:bids).count)
  end
end
