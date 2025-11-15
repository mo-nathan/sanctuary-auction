# frozen_string_literal: true

require 'test_helper'

class SiteDisabledControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @site_setting = SiteSetting.instance
  end

  # Access when site is disabled
  test 'index shows disabled page when site is disabled' do
    @site_setting.update(site_enabled: false)
    get site_disabled_path
    assert_response :success
    assert_select 'h1', text: 'Site Currently Unavailable'
    assert_select 'p.lead', text: 'This site is currently disabled for public use.'
  end

  test 'index shows disabled page when site is disabled by scheduled time' do
    @site_setting.update(
      site_enabled: true,
      site_disable_time: 1.hour.ago
    )
    get site_disabled_path
    assert_response :success
    assert_select 'h1', text: 'Site Currently Unavailable'
  end

  test 'index shows next enable time when set' do
    future_time = 2.hours.from_now
    @site_setting.update(
      site_enabled: false,
      site_enable_time: future_time
    )
    get site_disabled_path
    assert_response :success
    assert_select '.alert-info' do
      assert_select 'h4', text: 'Site Will Be Available:'
      assert_select 'p.mb-0.fs-4'
    end
  end

  test 'index does not show past enable time when site is disabled by disable_time' do
    @site_setting.update(
      site_enabled: true,
      site_enable_time: 2.hours.ago,
      site_disable_time: 1.hour.ago
    )
    get site_disabled_path
    assert_response :success
    assert_select '.alert-info', count: 0
  end

  test 'index shows admin sign in link' do
    @site_setting.update(site_enabled: false)
    get site_disabled_path
    assert_response :success
    assert_select 'a[href=?]', new_admin_session_path, text: 'sign in'
  end

  # Redirect when site is accessible
  test 'index redirects to root when site is enabled' do
    @site_setting.update(site_enabled: true)
    get site_disabled_path
    assert_redirected_to root_path
  end

  test 'index redirects to root when site is enabled by scheduled time' do
    @site_setting.update(
      site_enabled: false,
      site_enable_time: 1.hour.ago
    )
    get site_disabled_path
    assert_redirected_to root_path
  end

  # Admin access is always allowed
  test 'admins can access site_disabled page even when site is enabled' do
    sign_in admins(:admin_one)
    @site_setting.update(site_enabled: true)
    get site_disabled_path
    assert_redirected_to root_path
  end
end
