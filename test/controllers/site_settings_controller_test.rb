# frozen_string_literal: true

require 'test_helper'

class SiteSettingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @site_setting = SiteSetting.instance
  end

  # Authentication Tests
  test 'show requires admin authentication' do
    get site_settings_path
    assert_response :redirect
    assert_redirected_to new_admin_session_path
  end

  test 'update requires admin authentication' do
    patch site_settings_path, params: {
      site_setting: { site_enabled: false }
    }
    assert_response :redirect
    assert_redirected_to new_admin_session_path
  end

  # Show Action Tests
  test 'show renders settings form for admin' do
    sign_in admins(:admin_one)
    get site_settings_path
    assert_response :success
    assert_select 'h1', text: 'Site Settings'
    assert_select 'form[action=?]', site_settings_path
  end

  test 'show displays site access control section' do
    sign_in admins(:admin_one)
    get site_settings_path
    assert_response :success
    assert_select 'h3', text: 'Site Access Control'
    assert_select 'input[name="site_setting[site_enabled]"]'
    assert_select 'input[name="site_setting[site_enable_time]"]'
    assert_select 'input[name="site_setting[site_disable_time]"]'
  end

  test 'show displays limited bidding control section' do
    sign_in admins(:admin_one)
    get site_settings_path
    assert_response :success
    assert_select 'h3', text: 'Limited Item Bidding Control'
    assert_select 'input[name="site_setting[limited_bidding_enabled]"]'
    assert_select 'input[name="site_setting[limited_bidding_enable_time]"]'
    assert_select 'input[name="site_setting[limited_bidding_disable_time]"]'
  end

  test 'show displays current status' do
    sign_in admins(:admin_one)
    get site_settings_path
    assert_response :success
    assert_select 'h4', text: 'Current Status'
    assert_select 'strong', text: 'Site Accessible:'
    assert_select 'strong', text: 'Limited Bidding Allowed:'
  end

  test 'site enabled checkbox reflects scheduled state when enabled by schedule' do
    sign_in admins(:admin_one)
    @site_setting.update(
      site_enabled: false,
      site_enable_time: 1.hour.ago
    )
    get site_settings_path
    assert_response :success
    # Should be checked because site is accessible via schedule
    assert_select 'input[name="site_setting[site_enabled]"][checked="checked"]'
  end

  test 'site enabled checkbox reflects scheduled state when disabled by schedule' do
    sign_in admins(:admin_one)
    @site_setting.update(
      site_enabled: true,
      site_disable_time: 1.hour.ago
    )
    get site_settings_path
    assert_response :success
    # Should not be checked because site is disabled via schedule
    assert_select 'input[name="site_setting[site_enabled]"]:not([checked])'
  end

  # Update Action Tests
  test 'update changes site_enabled setting' do
    sign_in admins(:admin_one)
    patch site_settings_path, params: {
      site_setting: {
        site_enabled: false,
        limited_bidding_enabled: true
      }
    }
    assert_redirected_to site_settings_path
    assert_equal false, @site_setting.reload.site_enabled
    follow_redirect!
    assert_select '.alert', text: /Site settings updated successfully/
  end

  test 'update changes limited_bidding_enabled setting' do
    sign_in admins(:admin_one)
    patch site_settings_path, params: {
      site_setting: {
        site_enabled: true,
        limited_bidding_enabled: false
      }
    }
    assert_redirected_to site_settings_path
    assert_equal false, @site_setting.reload.limited_bidding_enabled
  end

  test 'update sets site_enable_time' do
    sign_in admins(:admin_one)
    future_time = '2025-12-25T10:00'
    patch site_settings_path, params: {
      site_setting: {
        site_enabled: true,
        limited_bidding_enabled: true,
        site_enable_time: future_time
      }
    }
    assert_redirected_to site_settings_path
    @site_setting.reload
    assert_not_nil @site_setting.site_enable_time
    # Verify it's parsed as Eastern time
    assert_equal 2025, @site_setting.site_enable_time.year
    assert_equal 12, @site_setting.site_enable_time.month
    assert_equal 25, @site_setting.site_enable_time.day
    assert_equal 10, @site_setting.site_enable_time.hour
  end

  test 'update sets site_disable_time' do
    sign_in admins(:admin_one)
    future_time = '2025-12-31T23:59'
    patch site_settings_path, params: {
      site_setting: {
        site_enabled: true,
        limited_bidding_enabled: true,
        site_disable_time: future_time
      }
    }
    assert_redirected_to site_settings_path
    @site_setting.reload
    assert_not_nil @site_setting.site_disable_time
    assert_equal 2025, @site_setting.site_disable_time.year
    assert_equal 12, @site_setting.site_disable_time.month
    assert_equal 31, @site_setting.site_disable_time.day
    assert_equal 23, @site_setting.site_disable_time.hour
    assert_equal 59, @site_setting.site_disable_time.min
  end

  test 'update sets limited_bidding_enable_time' do
    sign_in admins(:admin_one)
    future_time = '2025-11-20T14:30'
    patch site_settings_path, params: {
      site_setting: {
        site_enabled: true,
        limited_bidding_enabled: true,
        limited_bidding_enable_time: future_time
      }
    }
    assert_redirected_to site_settings_path
    @site_setting.reload
    assert_not_nil @site_setting.limited_bidding_enable_time
    assert_equal 2025, @site_setting.limited_bidding_enable_time.year
    assert_equal 11, @site_setting.limited_bidding_enable_time.month
    assert_equal 20, @site_setting.limited_bidding_enable_time.day
    assert_equal 14, @site_setting.limited_bidding_enable_time.hour
    assert_equal 30, @site_setting.limited_bidding_enable_time.min
  end

  test 'update sets limited_bidding_disable_time' do
    sign_in admins(:admin_one)
    future_time = '2025-11-21T18:00'
    patch site_settings_path, params: {
      site_setting: {
        site_enabled: true,
        limited_bidding_enabled: true,
        limited_bidding_disable_time: future_time
      }
    }
    assert_redirected_to site_settings_path
    @site_setting.reload
    assert_not_nil @site_setting.limited_bidding_disable_time
  end

  test 'update handles multiple settings at once' do
    sign_in admins(:admin_one)
    patch site_settings_path, params: {
      site_setting: {
        site_enabled: false,
        limited_bidding_enabled: false,
        site_enable_time: '2025-12-01T08:00',
        limited_bidding_enable_time: '2025-12-01T09:00'
      }
    }
    assert_redirected_to site_settings_path
    @site_setting.reload
    assert_equal false, @site_setting.site_enabled
    assert_equal false, @site_setting.limited_bidding_enabled
    assert_not_nil @site_setting.site_enable_time
    assert_not_nil @site_setting.limited_bidding_enable_time
  end

  test 'update handles empty datetime fields' do
    sign_in admins(:admin_one)
    @site_setting.update(site_enable_time: 1.day.from_now)
    patch site_settings_path, params: {
      site_setting: {
        site_enabled: true,
        limited_bidding_enabled: true,
        site_enable_time: ''
      }
    }
    assert_redirected_to site_settings_path
    # Empty string should not cause errors
  end

  test 'update parses datetime as Eastern time not UTC' do
    sign_in admins(:admin_one)
    # Set a specific time
    patch site_settings_path, params: {
      site_setting: {
        site_enabled: true,
        limited_bidding_enabled: true,
        site_enable_time: '2025-11-15T20:15'
      }
    }
    @site_setting.reload

    # Verify the time components match what was entered (Eastern time)
    assert_equal 2025, @site_setting.site_enable_time.year
    assert_equal 11, @site_setting.site_enable_time.month
    assert_equal 15, @site_setting.site_enable_time.day
    assert_equal 20, @site_setting.site_enable_time.hour
    assert_equal 15, @site_setting.site_enable_time.min

    # Verify it's in Eastern timezone
    assert_equal 'EST', @site_setting.site_enable_time.zone
  end
end
