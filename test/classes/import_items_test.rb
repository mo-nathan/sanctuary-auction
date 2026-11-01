# frozen_string_literal: true

require 'test_helper'

class ImportItemsTest < ActiveSupport::TestCase
  test 'should delete existing items' do
    ImportItems.import_from_csv('test/fixtures/items.csv')
    assert_equal(1, Item.count)
  end

  test 'should replace imgur page links' do
    Tempfile.create(['items', '.csv']) do |file|
      file.write("Title,Number,Image\nImgur Item,1,https://imgur.com/hkiJR5W\n")
      file.close
      ImportItems.import_from_csv(file.path)
    end
    assert_equal('https://i.imgur.com/hkiJR5W.jpeg', Item.sole.image_url)
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
