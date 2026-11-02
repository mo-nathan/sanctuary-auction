# frozen_string_literal: true

require 'application_system_test_case'

class ItemsTest < ApplicationSystemTestCase
  test 'opening the tag filter moves focus into it' do
    Tag.create!(name: 'Outdoors', group: 'Category')
    visit items_path
    click_button 'Filter by Tag'
    assert_equal('checkbox', evaluate_script('document.activeElement.type'))
  end
end
