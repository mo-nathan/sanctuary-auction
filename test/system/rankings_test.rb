# frozen_string_literal: true

require 'application_system_test_case'

class RankingsTest < ApplicationSystemTestCase
  def setup
    @user = users(:user_no_bids)
    %w[Alpha Bravo Charlie Delta].each { |title| Item.create!(title:, number: 1) }
    visit ranking_path
    fill_in 'code', with: @user.code
    click_on 'Continue'
    assert_text 'Your Ranking'
  end

  def ranked
    all('ol li a').map(&:text)
  end

  def unranked
    all('ul.list-group li a').map(&:text)
  end

  def press(action, title)
    click_on "#{action}: #{title}"
  end

  test 'moving items and saving assigns hearts by rank' do
    %w[Alpha Bravo Charlie Delta].each { |title| press('Add', title) }
    assert_equal(%w[Alpha Bravo Charlie Delta], ranked)

    press('Move up', 'Bravo')
    assert_equal(%w[Bravo Alpha Charlie Delta], ranked)
    press('Move down', 'Alpha')
    assert_equal(%w[Bravo Charlie Alpha Delta], ranked)
    press('Move to top', 'Delta')
    assert_equal(%w[Delta Bravo Charlie Alpha], ranked)
    press('Move to bottom', 'Bravo')
    assert_equal(%w[Delta Charlie Alpha Bravo], ranked)
    press('Remove', 'Charlie')
    assert_equal(%w[Delta Alpha Bravo], ranked)
    assert_includes(unranked.join(' '), 'Charlie')
    assert_equal(unranked.sort, unranked)

    click_on 'Save'
    assert_text 'Saved.'
    assert_equal(%w[Delta Alpha Bravo], ranked)
    assert_equal([30, 29, 28], @user.bids.joins(:item).order('bids.amount DESC').pluck(:amount))
  end

  test 'each section shows only its own controls' do
    press('Add', 'Alpha')

    assert_button 'Move up: Alpha', disabled: :all
    assert_no_button 'Add: Alpha'
    assert_button 'Add: Bravo'
    assert_no_button 'Remove: Bravo'
    assert_no_button 'Move up: Bravo', disabled: :all

    press('Remove', 'Alpha')
    assert_button 'Add: Alpha'
    assert_no_button 'Remove: Alpha'
  end

  test 'end positions disable the moves that do not apply' do
    %w[Alpha Bravo].each { |title| press('Add', title) }

    assert_button 'Move up: Alpha', disabled: true
    assert_button 'Move to top: Alpha', disabled: true
    assert_button 'Move down: Bravo', disabled: true
    assert_button 'Move to bottom: Bravo', disabled: true
    assert_button 'Move down: Alpha', disabled: false
    assert_button 'Move up: Bravo', disabled: false
  end
end
