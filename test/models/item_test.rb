# frozen_string_literal: true

require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test "should not save item without description" do
    item = Item.new
    assert_not item.save, "Saved the article without a description"
  end
end
