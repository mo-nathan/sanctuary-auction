# frozen_string_literal: true

require 'test_helper'

class BidTest < ActiveSupport::TestCase
  test 'run the bid report' do
    File.delete(Bid::REPORT_NAME) if File.file?(Bid::REPORT_NAME)
    Bid.report
    assert(File.file?(Bid::REPORT_NAME))
  end
end
