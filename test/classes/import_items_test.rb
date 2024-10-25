# frozen_string_literal: true

require 'test_helper'

class ImportItemsTest < ActiveSupport::TestCase
  test 'should import an item' do
    assert_difference('Item.count', 1) do
      ImportItems.import_from_csv('test/fixtures/items.csv')
    end
  end

  test 'should not find the file' do
    assert_difference('Item.count', 0) do
      ImportItems.import_from_csv('test/fixtures/no_such_file.csv')
    end
  end

  test 'report_on_result should handle nil' do
    assert_nil(ImportItems.report_on_result(nil, {}))
  end

  test 'should update da item' do
    ImportItems.import_from_csv('test/fixtures/items.csv')
    item = Item.find_by(host: 'Da Host')
    orig_description = item.description
    item.update(description: 'Not the description')
    assert_not_equal(item.reload.description, orig_description)
    ImportItems.import_from_csv('test/fixtures/items.csv')
    assert_equal(item.reload.description, orig_description)
  end

  test 'should delete extra tag' do
    Tag.destroy_all
    ImportItems.import_from_csv('test/fixtures/items.csv')
    item = Item.find_by(host: 'Da Host')
    tag_count = item.tags.count
    Tag.find_each do |tag|
      item.tags << tag unless item.tags.include?(tag)
    end
    assert_not_equal(tag_count, item.tags.count)
    ImportItems.import_from_csv('test/fixtures/items.csv')
    assert_equal(tag_count, item.tags.count)
  end
end
