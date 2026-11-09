# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'

class BidTest < ActiveSupport::TestCase
  test 'the bid report lists every bid under a header' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, Bid::REPORT_NAME)
      Bid.report(path)

      lines = File.readlines(path, chomp: true)
      assert_equal(Bid.count + 1, lines.size)
      assert_equal("User Name\tUser Code\tBid Amount\tItem Type\tItem Number\tItem Title", lines.first)
      bid = bids(:bid_three)
      assert_includes(lines, "#{bid.user.name}\t#{bid.user.code}\t#{bid.amount}\t" \
                             "#{bid.item.item_type}\t#{bid.item.number}\t#{bid.item.title}")
    end
  end
end
