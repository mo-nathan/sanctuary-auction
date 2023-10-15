# frozen_string_literal: true

require 'test_helper'

class ItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'show' do
    item = items(:item_one)
    get(item_path(id: item.id))
    assert_equal(200, @response.status)
  end

  test 'index' do
    get(items_path)
    assert_equal(200, @response.status)
  end

  test 'admin required' do
    get(new_item_path)
    assert_response :redirect
    follow_redirect!
  end

  test 'new' do
    sign_in(admins(:admin_one))
    get(new_item_path)
    assert_equal(200, @response.status)
  end

  test 'create' do
    sign_in(admins(:admin_one))
    before = Item.count
    post(items_path,
         params: { item: { description: 'can create' } })
    assert_response :redirect
    follow_redirect!
    assert_equal(before + 1, Item.count)
  end

  test 'create fail' do
    sign_in(admins(:admin_one))
    before = Item.count
    post(items_path,
         params: { item: { description: '' } })
    assert_response :unprocessable_entity
    assert_equal(before, Item.count)
  end

  test 'edit' do
    sign_in(admins(:admin_one))
    item = items(:item_one)
    get(edit_item_path(id: item.id))
    assert_equal(200, @response.status)
  end

  test 'update' do
    sign_in(admins(:admin_one))
    item = items(:item_one)
    after = "#{item.description} with a change"
    patch(item_path(id: item.id),
          params: { item: { description: after } })
    assert_response :redirect
    follow_redirect!
    item.reload
    assert_equal(after, item.description)
  end

  test 'update fail' do
    sign_in(admins(:admin_one))
    item = items(:item_one)
    before = item.description
    patch(item_path(id: item.id),
          params: { item: { description: '' } })
    assert_response :unprocessable_entity
    item.reload
    assert_equal(before, item.description)
  end

  test 'destroy' do
    sign_in(admins(:admin_one))
    item = items(:item_no_bids)
    delete(item_path(id: item.id))
    assert_response :redirect
    follow_redirect!
    assert_raises(ActiveRecord::RecordNotFound) do
      item.reload
    end
  end
end
