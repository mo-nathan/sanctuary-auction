# frozen_string_literal: true

require 'application_system_test_case'

class RankingsTest < ApplicationSystemTestCase
  def setup
    @user = users(:user_no_bids)
    %w[Alpha Bravo Charlie Delta].each { |title| Item.create!(title:, number: 1, description: "All about #{title}") }
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

  def row(title)
    find('li.list-group-item', text: title)
  end

  def press(label, title)
    row(title).click_button(label)
  end

  def focused
    evaluate_script('(() => { const a = document.activeElement; const li = a.closest("li"); ' \
                    'return [a.getAttribute("aria-label") || a.textContent.trim(), li && li.dataset.title] })()')
  end

  def assert_focused(expected)
    page.document.synchronize(3) { focused == expected || raise(Capybara::ElementNotFound) }
  rescue Capybara::ElementNotFound
    assert_equal(expected, focused)
  end

  def assert_announced(message)
    script = "document.querySelector('[data-ranking-target=status]').textContent"
    page.document.synchronize(3) { evaluate_script(script) == message || raise(Capybara::ElementNotFound) }
  end

  test 'moving items and saving assigns hearts by rank' do
    %w[Alpha Bravo Charlie Delta].each { |title| press('Add to Your List', title) }
    assert_equal(%w[Alpha Bravo Charlie Delta], ranked)

    press('Move Up One', 'Bravo')
    assert_equal(%w[Bravo Alpha Charlie Delta], ranked)
    press('Move Down One', 'Alpha')
    assert_equal(%w[Bravo Charlie Alpha Delta], ranked)
    press('Move to Top', 'Delta')
    assert_equal(%w[Delta Bravo Charlie Alpha], ranked)
    press('Move to Bottom', 'Bravo')
    assert_equal(%w[Delta Charlie Alpha Bravo], ranked)
    press('Remove from Your List', 'Charlie')
    assert_equal(%w[Delta Alpha Bravo], ranked)
    assert_includes(unranked.join(' '), 'Charlie')
    assert_equal(unranked.sort, unranked)

    click_on 'Save'
    assert_text 'Saved.'
    assert_equal(%w[Delta Alpha Bravo], ranked)
    assert_equal([30, 29, 28], @user.bids.joins(:item).order('bids.amount DESC').pluck(:amount))
  end

  test 'each section shows only its own controls' do
    press('Add to Your List', 'Alpha')

    assert(row('Alpha').has_button?('Move Up One', disabled: :all))
    assert(row('Alpha').has_no_button?('Add to Your List'))
    assert(row('Bravo').has_button?('Add to Your List'))
    assert(row('Bravo').has_no_button?('Remove from Your List'))
    assert(row('Bravo').has_no_button?('Move Up One', disabled: :all))

    press('Remove from Your List', 'Alpha')
    assert(row('Alpha').has_button?('Add to Your List'))
    assert(row('Alpha').has_no_button?('Remove from Your List'))
  end

  test 'end positions disable the moves that do not apply' do
    %w[Alpha Bravo].each { |title| press('Add to Your List', title) }

    assert(row('Alpha').has_button?('Move Up One', disabled: true))
    assert(row('Alpha').has_button?('Move to Top', disabled: true))
    assert(row('Bravo').has_button?('Move Down One', disabled: true))
    assert(row('Bravo').has_button?('Move to Bottom', disabled: true))
    assert(row('Alpha').has_button?('Move Down One', disabled: false))
    assert(row('Bravo').has_button?('Move Up One', disabled: false))
  end

  test 'details for an unranked item can add it' do
    click_on 'Bravo'
    within('.modal') do
      assert_text 'All about Bravo'
      assert_no_button 'Move Up One'
      click_button 'Add to Your List'
    end
    assert_no_selector '.modal.show'
    assert_equal(%w[Bravo], ranked)
  end

  test 'details for an unranked item can be cancelled' do
    click_on 'Charlie'
    within('.modal') { click_button 'Cancel' }
    assert_no_selector '.modal.show'
    assert_empty(ranked)
  end

  test 'details for a ranked item only close' do
    press('Add to Your List', 'Delta')
    click_on 'Delta'
    within('.modal') do
      assert_text 'All about Delta'
      assert_no_button 'Add to Your List'
      click_button 'Close', match: :first
    end
    assert_no_selector '.modal.show'
    assert_equal(%w[Delta], ranked)
  end

  test 'moving keeps focus on the moved item and announces its place' do
    %w[Alpha Bravo Charlie].each { |title| press('Add to Your List', title) }

    press('Move Up One', 'Charlie')
    assert_focused(['Move Up One', 'Charlie'])
    assert_announced('Charlie moved to 2 of 3')

    press('Move Up One', 'Charlie')
    assert_focused(['Move Down One', 'Charlie'])
    assert_announced('Charlie moved to 1 of 3')

    press('Move to Bottom', 'Charlie')
    assert_focused(['Move to Top', 'Charlie'])
  end

  test 'adding moves focus to the next item to add' do
    press('Add to Your List', 'Alpha')
    assert_focused(['Add to Your List', 'Bravo'])
    assert_announced('Alpha added at 1 of 1')
  end

  test 'removing moves focus to the next ranked item' do
    %w[Alpha Bravo].each { |title| press('Add to Your List', title) }

    press('Remove from Your List', 'Alpha')
    assert_focused(['Remove from Your List', 'Bravo'])
    assert_announced('Alpha removed from your list')

    press('Remove from Your List', 'Bravo')
    assert_focused(['Add to Your List', 'Bravo'])
  end

  test 'closing details returns focus to the item' do
    click_on 'Charlie'
    within('.modal') { click_button 'Cancel' }
    assert_no_selector '.modal.show'
    assert_focused(%w[Charlie Charlie])
  end

  test 'adding from details moves focus to the next item to add' do
    click_on 'Charlie'
    within('.modal') { click_button 'Add to Your List' }
    assert_no_selector '.modal.show'
    assert_focused(['Add to Your List', 'Delta'])
    assert_announced('Charlie added at 1 of 1')
  end
end
