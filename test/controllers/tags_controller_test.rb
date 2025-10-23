# frozen_string_literal: true

require 'test_helper'

class TagsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    sign_in(admins(:admin_one))
  end

  test 'should get index' do
    get tags_url
    assert_response :success
    assert_select 'h1', 'All Tags'
  end

  test 'should get show' do
    tag = tags(:one)
    get tag_url(tag)
    assert_response :success

    assert_select 'h1', "#{tag.group}: #{tag.name} Tag"
  end

  test 'should get new' do
    get new_tag_url
    assert_response :success
    assert_select 'form'
  end

  test 'should create a new tag' do
    assert_difference('Tag.count', 1) do
      post tags_url, params: { tag: { name: 'New Tag' } }
    end
    assert_redirected_to tags_url
    follow_redirect!
    assert_response :success
    tag = Tag.find_by(name: 'New Tag')
    assert_select 'div.alert.alert-success', "#{tag.name} tag created."
  end

  test 'should fail to create duplicate tag' do
    name = tags(:two).name
    assert_difference('Tag.count', 0) do
      post tags_url(tag: { name: })
    end
    assert_response :unprocessable_content
    assert_select 'div.error', /Name has already been taken/
  end

  test 'non-admin should fail to create tag' do
    sign_out(admins(:admin_one))
    name = 'Non-admin tag'
    assert_difference('Tag.count', 0) do
      post tags_url(tag: { name: })
    end
    assert_redirected_to root_path
  end

  test 'should get edit' do
    get edit_tag_url(tags(:one))
    assert_response :success
    assert_select 'form'
  end

  test 'should update tag name' do
    tag = tags(:one)
    patch tag_url(tag, tag: { name: 'Won' })
    assert_redirected_to tags_url
    follow_redirect!
    assert_response :success
    tag.reload
    assert_equal 'Won', tag.name
    assert_select 'div.alert.alert-success', 'Tag was successfully updated.'
  end

  test 'should fail to update with duplicate name' do
    tag = tags(:one)
    patch tag_url(tag, tag: { name: tags(:two).name })
    assert_response :unprocessable_content
    assert_select 'div.error', /Name has already been taken/
  end

  test 'should destroy tag' do
    tag = tags(:one)
    name = tag.name
    assert_difference('Tag.count', -1) do
      delete tag_url(tag)
    end
    assert_redirected_to tags_url
    follow_redirect!
    assert_response :success
    assert_select 'div.alert.alert-success', "#{name} tag successfully destroyed."
  end
end
