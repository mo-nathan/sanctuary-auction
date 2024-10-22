# frozen_string_literal: true

require 'test_helper'

class ItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'show' do
    item = items(:item_one)
    get(item_path(id: item.id))
    assert_response :success
    assert_select('br', count: 0)
  end

  test 'show long description' do
    item = items(:item_with_long_description)
    get(item_path(id: item.id))
    assert_response :success
    assert_select('br', count: 1)
  end

  test 'index default' do
    get(items_path)
    assert_response :success
    # assert_match items(:item_one).title, @response.body
    assert_select 'span', text: items(:item_one).title
    assert_select 'span', text: items(:item_two).title
  end

  test 'index tag test' do
    get(items_path(tag_ids: [tags(:one).id.to_s]))
    assert_response :success
    assert_select 'span', text: items(:item_one).title
    assert_select 'span', text: items(:item_two).title, count: 0
  end

  test 'index auction' do
    get(items_path(type: 'Auction'))
    assert_response :success
  end

  test 'index buy-in' do
    get(items_path(type: 'Buy-In'))
    assert_response :success
  end

  test 'admin required' do
    get(new_item_path)
    assert_response :redirect
    follow_redirect!
  end

  test 'new' do
    sign_in(admins(:admin_one))
    get(new_item_path)
    assert_response :success
  end

  test 'create' do
    sign_in(admins(:admin_one))
    before = Item.count
    post(items_path,
         params: { item: { title: 'can create', number: 1 } })
    assert_response :redirect
    follow_redirect!
    assert_equal(before + 1, Item.count)
  end

  test 'create fail' do
    sign_in(admins(:admin_one))
    before = Item.count
    post(items_path,
         params: { item: { title: '' } })
    assert_response :unprocessable_entity
    assert_equal(before, Item.count)
  end

  test 'edit' do
    sign_in(admins(:admin_one))
    item = items(:item_one)
    get(edit_item_path(id: item.id))
    assert_response :success
  end

  test 'update title' do
    sign_in(admins(:admin_one))
    item = items(:item_one)
    after = "#{item.title} with a change"
    patch(item_path(id: item.id),
          params: { item: { title: after } })
    assert_response :redirect
    follow_redirect!
    item.reload
    assert_equal(after, item.title)
  end

  test 'update format' do
    sign_in(admins(:admin_one))
    item = items(:item_one)
    after = "#{item.format} with a change"
    patch(item_path(id: item.id),
          params: { item: { format: after } })
    assert_response :redirect
    follow_redirect!
    item.reload
    assert_equal(after, item.format)
  end

  test 'update timing' do
    sign_in(admins(:admin_one))
    item = items(:item_one)
    date = Time.zone.today.strftime('%B %e')
    patch(item_path(id: item.id),
          params: { item: { timing: date } })
    assert_response :redirect
    follow_redirect!
    item.reload
    assert_equal(date, item.timing)
  end

  test 'update fail' do
    sign_in(admins(:admin_one))
    item = items(:item_one)
    before = item.title
    patch(item_path(id: item.id),
          params: { item: { title: '' } })
    assert_response :unprocessable_entity
    item.reload
    assert_equal(before, item.title)
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
