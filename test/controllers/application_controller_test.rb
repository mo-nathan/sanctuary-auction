# frozen_string_literal: true

require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @site_setting = SiteSetting.instance
  end

  test 'check_site_access redirects to site_disabled_path when site is disabled' do
    @site_setting.update(site_enabled: false)

    # Access any page as non-admin to trigger check_site_access
    get root_path

    assert_redirected_to site_disabled_path
  end

  test 'check_site_access allows access when site is enabled' do
    @site_setting.update(site_enabled: true)

    get root_path

    assert_response :success
  end

  test 'check_site_access allows admin access even when site is disabled' do
    @site_setting.update(site_enabled: false)
    sign_in admins(:admin_one)

    get root_path

    assert_response :success
  end

  test 'limited_bidding_allowed? helper returns correct value' do
    @site_setting.update(limited_bidding_enabled: true)
    get root_path
    assert SiteSetting.limited_bidding_allowed?

    @site_setting.update(limited_bidding_enabled: false)
    get root_path
    assert_not SiteSetting.limited_bidding_allowed?
  end
end
