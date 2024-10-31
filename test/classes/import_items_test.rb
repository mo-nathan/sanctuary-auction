# frozen_string_literal: true

require 'test_helper'

class ImportItemsTest < ActiveSupport::TestCase
  test 'should delete existing items' do
    ImportItems.import_from_csv('test/fixtures/items.csv')
    assert_equal(1, Item.count)
  end

  test 'should not find the file' do
    assert_difference('Item.count', 0) do
      ImportItems.import_from_csv('test/fixtures/no_such_file.csv')
    end
  end

  test 'report_on_result should handle nil' do
    assert_nil(ImportItems.report_on_result(nil, {}))
  end
end
