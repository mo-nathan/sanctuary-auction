# frozen_string_literal: true

require 'test_helper'

class ItemsControllerTest < ActionDispatch::IntegrationTest
  test 'show' do
    item = items(:one)
    get(item_path(id: item.id))
    assert_equal(200, @response.status)
  end

  test 'index' do
    get(items_path)
    assert_equal(200, @response.status)
  end

  test 'new' do
    get(new_item_path)
    assert_equal(200, @response.status)
  end

  test 'create' do
    before = Item.count
    post(items_path,
         params: { item: { description: 'can create' } })
    assert_response :redirect
    follow_redirect!
    assert_equal(before + 1, Item.count)
  end

  test 'create fail' do
    before = Item.count
    post(items_path,
         params: { item: { description: '' } })
    assert_response :unprocessable_entity
    assert_equal(before, Item.count)
  end

  test 'edit' do
    item = items(:one)
    get(edit_item_path(id: item.id))
    assert_equal(200, @response.status)
  end

  test 'update' do
    item = items(:one)
    after = "#{item.description} with a change"
    patch(item_path(id: item.id),
          params: { item: { description: after } })
    assert_response :redirect
    follow_redirect!
    item.reload
    assert_equal(after, item.description)
  end

  test 'update fail' do
    item = items(:one)
    before = item.description
    patch(item_path(id: item.id),
          params: { item: { description: '' } })
    assert_response :unprocessable_entity
    item.reload
    assert_equal(before, item.description)
  end
end
