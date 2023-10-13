# frozen_string_literal: true

require 'test_helper'

class ItemsControllerTest < ActionDispatch::IntegrationTest
  test 'show' do
    item = items(:one)
    get(item_path(id: item.id))
    assert_equal(200, @response.status)
  end
end
