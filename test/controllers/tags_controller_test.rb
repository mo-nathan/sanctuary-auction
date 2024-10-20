# frozen_string_literal: true

require 'test_helper'

class TagsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get tags_url
    assert_response :success
  end

  test 'should get show' do
    get tag_url(tags(:one))
    assert_response :success
  end

  test 'should get new' do
    get new_tag_url
    assert_response :success
  end

  test 'should create new tag' do
    post tags_url(tag: { name: 'New Tag' })
    assert_response :redirect
    tag = Tag.last
    assert_equal(tag.name, 'New Tag')
  end

  test 'should fail create' do
    post tags_url(tag: { name: tags(:two).name })
    assert_response :unprocessable_entity
  end

  test 'should get edit' do
    get edit_tag_url(tags(:one))
    assert_response :success
  end

  test 'should update tag name' do
    tag = tags(:one)
    put tag_url(tag, tag: { name: 'Won' })
    assert_response :redirect
    tag.reload
    assert_equal(tag.name, 'Won')
  end

  test 'should fail update' do
    tag = tags(:one)
    put tag_url(tag, tag: { name: tags(:two).name })
    assert_response :unprocessable_entity
  end

  test 'should destroy tag' do
    delete tag_url(tags(:one))
    assert_response :redirect
  end
end
