# frozen_string_literal: true

require 'test_helper'

class AwardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @awards_dir = Rails.root.join('tmp/awards')
    FileUtils.mkdir_p(@awards_dir)
  end

  teardown do
    # Clean up any test award files
    FileUtils.rm_rf(@awards_dir) if File.directory?(@awards_dir)
  end

  # Helper to create test award files
  def create_test_award_file(filename)
    filepath = @awards_dir.join(filename)
    File.write(filepath, "Winner,Item,Host\nTest User,Test Item,Test Host\n")
    filename
  end

  # Authentication Tests
  test 'index requires admin authentication' do
    get awards_path
    assert_response :redirect
    assert_redirected_to new_admin_session_path
  end

  test 'create requires admin authentication' do
    post awards_path
    assert_response :redirect
    assert_redirected_to new_admin_session_path
  end

  test 'download requires admin authentication' do
    filename = create_test_award_file('awards_20251116_120000.csv')
    get download_awards_path(filename)
    assert_response :unauthorized
  end

  test 'destroy requires admin authentication' do
    filename = create_test_award_file('awards_20251116_120000.csv')
    delete delete_awards_path(filename)
    assert_response :unauthorized
  end

  # Index Action Tests
  test 'index shows empty state when no awards exist' do
    sign_in admins(:admin_one)
    get awards_path
    assert_response :success
    assert_select 'h1', text: 'Awards'
    assert_select 'p', text: 'No awards have been generated yet.'
    assert_select 'button', text: 'Generate First Award'
  end

  test 'index lists existing award files' do
    sign_in admins(:admin_one)
    create_test_award_file('awards_20251116_120000.csv')
    create_test_award_file('awards_20251116_130000.csv')

    get awards_path
    assert_response :success
    assert_select 'h3', text: 'Previous Awards'
    assert_select 'li.list-group-item', count: 2
    assert_select 'button', text: 'Generate New Award'
  end

  test 'index shows formatted dates for award files' do
    sign_in admins(:admin_one)
    create_test_award_file('awards_20251116_213045.csv')

    get awards_path
    assert_response :success
    assert_select 'li.list-group-item', text: /2025-11-16 21:30:45/
  end

  test 'index shows download buttons for each award' do
    sign_in admins(:admin_one)
    create_test_award_file('awards_20251116_120000.csv')

    get awards_path
    assert_response :success
    assert_select 'a.btn-info', text: 'Download'
  end

  test 'index shows delete buttons for each award' do
    sign_in admins(:admin_one)
    create_test_award_file('awards_20251116_120000.csv')

    get awards_path
    assert_response :success
    assert_select 'button.btn-danger', text: 'Delete'
  end

  test 'index sorts award files in reverse chronological order' do
    sign_in admins(:admin_one)
    create_test_award_file('awards_20251116_120000.csv')
    create_test_award_file('awards_20251116_130000.csv')
    create_test_award_file('awards_20251116_110000.csv')

    get awards_path
    assert_response :success

    # Get all list items
    doc = Nokogiri::HTML(response.body)
    dates = doc.css('li.list-group-item').map(&:text).map(&:strip)

    # Newest should be first
    assert dates[0].include?('2025-11-16 13:00:00'), 'Newest award should be first'
    assert dates[1].include?('2025-11-16 12:00:00'), 'Middle award should be second'
    assert dates[2].include?('2025-11-16 11:00:00'), 'Oldest award should be last'
  end

  # Create Action Tests
  test 'create generates award file and redirects' do
    sign_in admins(:admin_one)

    # Create some test data
    user = users(:user_one)
    item = items(:item_one)
    Bid.create!(user:, item:, amount: 10)

    post awards_path
    assert_response :redirect
    assert_redirected_to awards_path
    assert flash[:download_filename].present?
  end

  test 'create saves CSV file to awards directory' do
    sign_in admins(:admin_one)

    # Create some test data
    user = users(:user_one)
    item = items(:item_one)
    Bid.create!(user:, item:, amount: 10)

    post awards_path

    filename = flash[:download_filename]
    filepath = @awards_dir.join(filename)
    assert File.exist?(filepath), 'Award file should be created'
  end

  test 'create generates filename with timestamp' do
    sign_in admins(:admin_one)

    # Create some test data
    user = users(:user_one)
    item = items(:item_one)
    Bid.create!(user:, item:, amount: 10)

    post awards_path

    filename = flash[:download_filename]
    assert_match(/awards_\d{8}_\d{6}\.csv/, filename)
  end

  test 'create generates CSV with correct headers' do
    sign_in admins(:admin_one)

    # Create some test data
    user = users(:user_one)
    item = items(:item_one)
    Bid.create!(user:, item:, amount: 10)

    post awards_path

    filename = flash[:download_filename]
    filepath = @awards_dir.join(filename)
    csv_content = File.read(filepath)

    assert csv_content.include?('Winner,Item,Host')
  end

  test 'create works with no bids' do
    sign_in admins(:admin_one)

    # Clear all bids
    Bid.destroy_all

    post awards_path
    assert_response :redirect
    assert_redirected_to awards_path
    assert flash[:download_filename].present?
  end

  # Download Action Tests
  test 'download sends existing file' do
    sign_in admins(:admin_one)
    filename = create_test_award_file('awards_20251116_120000.csv')

    get download_awards_path(filename)
    assert_response :success
    assert_equal 'text/csv', response.content_type
    assert_match(/attachment/, response.headers['Content-Disposition'])
    assert_match(/#{filename}/, response.headers['Content-Disposition'])
  end

  test 'download redirects when file not found' do
    sign_in admins(:admin_one)

    get download_awards_path('awards_20251116_999999.csv')
    assert_response :redirect
    assert_redirected_to awards_path
    assert_equal I18n.t('awards.file_not_found'), flash[:alert]
  end

  test 'download sends file content correctly' do
    sign_in admins(:admin_one)
    filename = create_test_award_file('awards_20251116_120000.csv')

    get download_awards_path(filename)
    assert_response :success
    assert response.body.include?('Winner,Item,Host')
    assert response.body.include?('Test User,Test Item,Test Host')
  end

  # Destroy Action Tests
  test 'destroy deletes existing file' do
    sign_in admins(:admin_one)
    filename = create_test_award_file('awards_20251116_120000.csv')
    filepath = @awards_dir.join(filename)

    assert File.exist?(filepath), 'File should exist before delete'

    delete delete_awards_path(filename)
    assert_response :redirect
    assert_redirected_to awards_path
    assert_equal I18n.t('awards.file_deleted'), flash[:notice]
    assert_not File.exist?(filepath), 'File should not exist after delete'
  end

  test 'destroy redirects when file not found' do
    sign_in admins(:admin_one)

    delete delete_awards_path('awards_20251116_999999.csv')
    assert_response :redirect
    assert_redirected_to awards_path
    assert_equal I18n.t('awards.file_not_found'), flash[:alert]
  end

  test 'destroy removes file from filesystem' do
    sign_in admins(:admin_one)
    filename = create_test_award_file('awards_20251116_120000.csv')
    filepath = @awards_dir.join(filename)

    # Verify file exists
    assert File.exist?(filepath)

    # Delete it
    delete delete_awards_path(filename)

    # Verify it's gone
    assert_not File.exist?(filepath)
  end

  test 'destroy only deletes specified file' do
    sign_in admins(:admin_one)
    filename1 = create_test_award_file('awards_20251116_120000.csv')
    filename2 = create_test_award_file('awards_20251116_130000.csv')
    filepath1 = @awards_dir.join(filename1)
    filepath2 = @awards_dir.join(filename2)

    # Delete first file
    delete delete_awards_path(filename1)

    # Verify only first file is deleted
    assert_not File.exist?(filepath1)
    assert File.exist?(filepath2)
  end

  # Index with auto-download trigger
  test 'index includes download trigger when flash contains filename' do
    sign_in admins(:admin_one)

    # Simulate redirect from create with flash by posting first
    post awards_path
    follow_redirect!

    assert_response :success
    assert_select 'iframe'
  end

  test 'index does not include download trigger when no flash' do
    sign_in admins(:admin_one)
    create_test_award_file('awards_20251116_120000.csv')

    get awards_path
    assert_response :success
    assert_select 'iframe', count: 0
  end
end
