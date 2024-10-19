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

  test 'should get create' do
    post tags_url
    assert_response :success
  end

  test 'should get edit' do
    get edit_tag_url(tags(:one))
    assert_response :success
  end

  test 'should get update' do
    put tag_url(tags(:one))
    assert_response :success
  end

  test 'should get destroy' do
    delete tag_url(tags(:one))
    assert_response :success
  end
end
