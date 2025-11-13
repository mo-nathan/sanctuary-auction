# frozen_string_literal: true

require 'test_helper'
require 'csv'

class ItemsCsvControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @csv_file_path = Rails.root.join('test', 'fixtures', 'items.csv')
    @csv_file = fixture_file_upload(@csv_file_path, 'text/csv')
  end

  teardown do
    # Clean up any temporary files
    Dir[Rails.root.join('tmp', 'uploads', 'items_import_*.csv')].each do |file|
      File.delete(file) if File.exist?(file)
    end
  end

  # Authentication Tests
  test 'new requires admin authentication' do
    get new_items_csv_path
    assert_response :redirect
    assert_redirected_to new_admin_session_path
  end

  test 'preview requires admin authentication' do
    post preview_items_csv_path, params: { csv_file: @csv_file }
    assert_response :redirect
    assert_redirected_to new_admin_session_path
  end

  test 'create requires admin authentication' do
    post items_csv_path
    assert_response :redirect
    assert_redirected_to new_admin_session_path
  end

  # New Action Tests
  test 'new renders upload form' do
    sign_in admins(:admin_one)
    get new_items_csv_path
    assert_response :success
    assert_select 'h1', text: 'Upload Items CSV'
    assert_select 'input[type=file][name="csv_file"]'
    assert_select 'input[type=submit][value="Preview Import"]'
  end

  test 'new shows warning message' do
    sign_in admins(:admin_one)
    get new_items_csv_path
    assert_response :success
    assert_select '.alert.alert-warning', text: /delete ALL existing items/
  end

  # Preview Action Tests
  test 'preview with valid CSV shows item count' do
    sign_in admins(:admin_one)
    post preview_items_csv_path, params: { csv_file: @csv_file }
    assert_response :success
    assert_select 'h1', text: 'Confirm CSV Import'
    assert_select '.alert.alert-info', text: /1 item found/
    assert session[:csv_temp_path].present?
  end

  test 'preview with no file redirects with alert' do
    sign_in admins(:admin_one)
    post preview_items_csv_path
    assert_response :redirect
    assert_redirected_to new_items_csv_path
    assert_equal I18n.t('items.csv.no_file'), flash[:alert]
  end

  test 'preview with invalid CSV redirects with error' do
    sign_in admins(:admin_one)
    invalid_csv = fixture_file_upload(
      Rails.root.join('test', 'fixtures', 'files', 'invalid.csv'),
      'text/csv'
    )
    post preview_items_csv_path, params: { csv_file: invalid_csv }
    assert_response :redirect
    assert_redirected_to new_items_csv_path
    assert flash[:alert].present?
    assert flash[:alert].include?('Error reading CSV file')
  end

  test 'preview saves CSV to temp directory' do
    sign_in admins(:admin_one)
    post preview_items_csv_path, params: { csv_file: @csv_file }
    assert_response :success

    temp_path = session[:csv_temp_path]
    assert temp_path.present?
    assert File.exist?(temp_path)
    assert temp_path.include?('tmp/uploads')
  end

  test 'preview with multiple items shows correct count' do
    sign_in admins(:admin_one)
    multi_csv = fixture_file_upload(
      Rails.root.join('test', 'fixtures', 'files', 'multi_items.csv'),
      'text/csv'
    )

    post preview_items_csv_path, params: { csv_file: multi_csv }
    assert_response :success
    assert_select '.alert.alert-info', text: /2 items found/
  end

  test 'preview shows confirm import button' do
    sign_in admins(:admin_one)
    post preview_items_csv_path, params: { csv_file: @csv_file }
    assert_response :success
    assert_select 'input[type=submit][value="Confirm Import"]'
    assert_select 'a', text: 'Cancel'
  end

  test 'preview shows final warning' do
    sign_in admins(:admin_one)
    post preview_items_csv_path, params: { csv_file: @csv_file }
    assert_response :success
    assert_select '.alert.alert-danger', text: /Final Warning/
  end

  # Create Action Tests
  test 'create imports CSV and redirects to items' do
    sign_in admins(:admin_one)

    # First preview to set up session
    post preview_items_csv_path, params: { csv_file: @csv_file }
    assert_response :success

    # Count items before import
    before_count = Item.count

    # Perform import
    post items_csv_path
    assert_response :redirect
    assert_redirected_to items_path
    assert_equal I18n.t('items.csv.import_success'), flash[:notice]

    # Verify items were imported
    assert Item.count >= 1, 'Items should be created from CSV'
  end

  test 'create with no temp file redirects with alert' do
    sign_in admins(:admin_one)
    post items_csv_path
    assert_response :redirect
    assert_redirected_to new_items_csv_path
    assert_equal I18n.t('items.csv.no_temp_file'), flash[:alert]
  end

  test 'create with missing temp file redirects with alert' do
    sign_in admins(:admin_one)

    # Set a session path that doesn't exist
    post preview_items_csv_path, params: { csv_file: @csv_file }
    temp_path = session[:csv_temp_path]
    File.delete(temp_path) if File.exist?(temp_path)

    post items_csv_path
    assert_response :redirect
    assert_redirected_to new_items_csv_path
    assert_equal I18n.t('items.csv.no_temp_file'), flash[:alert]
  end

  test 'create cleans up temp file after import' do
    sign_in admins(:admin_one)

    # Preview to create temp file
    post preview_items_csv_path, params: { csv_file: @csv_file }
    temp_path = session[:csv_temp_path]
    assert File.exist?(temp_path)

    # Import
    post items_csv_path

    # Verify temp file was deleted
    assert_not File.exist?(temp_path)
    assert_nil session[:csv_temp_path]
  end

  test 'create clears session data after import' do
    sign_in admins(:admin_one)

    # Preview
    post preview_items_csv_path, params: { csv_file: @csv_file }
    assert session[:csv_temp_path].present?

    # Import
    post items_csv_path

    # Verify session cleared
    assert_nil session[:csv_temp_path]
  end

  test 'create imports items with correct attributes' do
    sign_in admins(:admin_one)

    # Preview
    post preview_items_csv_path, params: { csv_file: @csv_file }

    # Import
    Item.destroy_all
    post items_csv_path

    # Verify item was created with correct attributes
    item = Item.find_by(title: 'Da Item')
    assert_not_nil item
    assert_equal 'Da Host', item.host
    assert_equal 'So amazing', item.description.split("\n\n").first
    assert_equal 3, item.number
    assert_equal 'Tomorrow', item.timing
  end

  test 'create imports tags correctly' do
    sign_in admins(:admin_one)

    # Preview
    post preview_items_csv_path, params: { csv_file: @csv_file }

    # Import (this calls Tagger.create_tags and ImportItems.import_from_csv)
    Tag.destroy_all
    Item.destroy_all
    post items_csv_path

    # Verify tags were created
    assert Tag.count.positive?, 'Tags should be created'

    # Verify item has correct tags
    item = Item.find_by(title: 'Da Item')
    assert_not_nil item

    # Check for expected tags based on CSV (Object_Mail: 1 - Yes, Food: 1 - Yes, Family: 1 - Yes)
    tag_names = item.tags.pluck(:name)
    assert tag_names.any? { |name| name.include?('Mail') }, 'Item should have Mail-related tag'
    assert tag_names.any? { |name| name.include?('Food') }, 'Item should have Food-related tag'
  end

  test 'create with valid CSV succeeds even if file has no items' do
    sign_in admins(:admin_one)

    # Create a CSV with only headers (no data rows)
    empty_csv_path = Rails.root.join('tmp', 'empty.csv')
    File.write(empty_csv_path, "Host,Title,Description,Number\n")

    post preview_items_csv_path, params: { csv_file: fixture_file_upload(empty_csv_path, 'text/csv') }
    assert_response :success
    assert_select '.alert.alert-info', text: /0 items found/

    # Should still succeed (ImportItems handles this gracefully)
    post items_csv_path
    assert_response :redirect
    assert_redirected_to items_path

    File.delete(empty_csv_path) if File.exist?(empty_csv_path)
  end

  test 'create is destructive and replaces all items' do
    sign_in admins(:admin_one)

    # Create some existing items
    existing_item = Item.create!(title: 'Existing Item', number: 5)
    before_id = existing_item.id

    # Preview and import
    post preview_items_csv_path, params: { csv_file: @csv_file }
    post items_csv_path

    # Verify old items are gone
    assert_raises(ActiveRecord::RecordNotFound) do
      Item.find(before_id)
    end
  end

  # Edge Cases
  test 'preview cleans up temp file on CSV read error' do
    sign_in admins(:admin_one)

    # Use the invalid CSV fixture that will cause parsing to fail
    invalid_csv = fixture_file_upload(
      Rails.root.join('test', 'fixtures', 'files', 'invalid.csv'),
      'text/csv'
    )

    post preview_items_csv_path, params: { csv_file: invalid_csv }

    # Should redirect with error
    assert_response :redirect
    assert_redirected_to new_items_csv_path
    assert flash[:alert].present?

    # Verify temp file was cleaned up (no orphaned files from this upload)
    temp_files = Dir[Rails.root.join('tmp', 'uploads', 'items_import_*.csv')]
    # If any temp files exist, they shouldn't contain our invalid content
    temp_files.each do |file|
      content = File.read(file) if File.exist?(file)
      assert_not content&.include?('This is not a proper CSV file')
    end
  end
end
