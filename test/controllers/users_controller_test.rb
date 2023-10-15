# frozen_string_literal: true

require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'show' do
    user = users(:user_one)
    get(user_path(id: user.id))
    assert_equal(200, @response.status)
  end

  test 'index' do
    get(users_path)
    assert_equal(200, @response.status)
  end

  test 'new' do
    sign_in(admins(:admin_one))
    get(new_user_path)
    assert_equal(200, @response.status)
  end

  test 'create' do
    sign_in(admins(:admin_one))
    before = User.count
    post(users_path,
         params: { user: { code: 'xyz', name: 'Rainey' } })
    assert_response :redirect
    follow_redirect!
    assert_equal(before + 1, User.count)
  end

  test 'create fail' do
    sign_in(admins(:admin_one))
    before = User.count
    post(users_path,
         params: { user: { name: '' } })
    assert_response :unprocessable_entity
    assert_equal(before, User.count)
  end

  test 'edit' do
    sign_in(admins(:admin_one))
    user = users(:user_one)
    get(edit_user_path(id: user.id))
    assert_equal(200, @response.status)
  end

  test 'update' do
    sign_in(admins(:admin_one))
    user = users(:user_one)
    after = "#{user.name} with a change"
    patch(user_path(id: user.id),
          params: { user: { name: after } })
    assert_response :redirect
    follow_redirect!
    user.reload
    assert_equal(after, user.name)
  end

  test 'update fail' do
    sign_in(admins(:admin_one))
    user = users(:user_one)
    before = user.name
    patch(user_path(id: user.id),
          params: { user: { name: '' } })
    assert_response :unprocessable_entity
    user.reload
    assert_equal(before, user.name)
  end

  test 'destroy' do
    sign_in(admins(:admin_one))
    user = users(:user_no_bids)
    delete(user_path(id: user.id))
    assert_response :redirect
    follow_redirect!
    assert_raises(ActiveRecord::RecordNotFound) do
      user.reload
    end
  end
end
