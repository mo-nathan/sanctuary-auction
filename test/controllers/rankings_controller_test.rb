# frozen_string_literal: true

require 'test_helper'

class RankingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'show asks for a code' do
    get ranking_path

    assert_response :success
    assert_select "input[name='code']"
  end

  test 'create shows ranked and unranked items with the code in a hidden field' do
    post ranking_path, params: { code: " #{users(:user_one).code.upcase} " }

    assert_response :success
    assert_select "input[type='hidden'][name='code'][value=?]", users(:user_one).code
    assert_select "ol li input[name='item_ids[]'][value=?]", items(:item_three).id.to_s
    assert_select "ul li input[name='item_ids[]'][value=?][disabled]", items(:item_two).id.to_s
    assert_select 'li a', { text: items(:item_one).title, count: 0 }
  end

  test 'create labels the controls and includes item details' do
    post ranking_path, params: { code: users(:user_one).code }

    RankingsHelper::RANKING_MOVES.each do |move|
      assert_select 'button[aria-label=?]', move[:label]
    end
    assert_select 'button[aria-label=?]', RankingsHelper::ADD_MOVE[:label]
    assert_select 'template', /#{items(:item_three).description}/
  end

  test 'create ties each button to its item title' do
    post ranking_path, params: { code: users(:user_one).code }

    title_id = "item-title-#{items(:item_three).id}"
    assert_select "a##{title_id}", text: items(:item_three).title
    assert_select "button[aria-describedby='#{title_id}']", count: RankingsHelper::RANKING_MOVES.size + 1
    assert_select '[aria-live=polite]'
  end

  test 'create with an unknown code returns to the code form' do
    post ranking_path, params: { code: 'nobody' }

    assert_redirected_to ranking_path
    assert_match('nobody', flash[:alert])
  end

  test 'update saves the ranking' do
    user = users(:user_two)
    patch ranking_path, params: { code: user.code, item_ids: [items(:item_two).id, items(:item_three).id] }

    assert_response :success
    assert_equal(31, user.bids.find_by(item: items(:item_two)).amount)
    assert_equal(30, user.bids.find_by(item: items(:item_three)).amount)
    assert_equal(459, user.reload.balance)
    assert_match('459 hearts left', flash[:notice])
  end

  test 'update without items clears the ranking' do
    user = users(:user_two)
    patch ranking_path, params: { code: user.code }

    assert_response :success
    assert_empty(user.bids)
  end

  test 'update with an unknown code saves nothing' do
    before = Bid.count
    patch ranking_path, params: { code: 'nobody', item_ids: [items(:item_two).id] }

    assert_redirected_to ranking_path
    assert_equal(before, Bid.count)
  end

  test 'closed bidding blocks ranking' do
    SiteSetting.instance.update!(limited_bidding_enabled: false)
    user = users(:user_two)
    patch ranking_path, params: { code: user.code }

    assert_redirected_to root_path
    assert_equal(I18n.t('bids.limited_bidding_disabled'), flash[:alert])
    assert_equal(2, user.bids.count)
  end

  test 'closed bidding hides the tab from everyone but admins' do
    SiteSetting.instance.update!(limited_bidding_enabled: false)
    get root_path
    assert_select 'nav a.nav-link', { text: 'Fairy Helper', count: 0 }

    sign_in admins(:admin_one)
    get root_path
    assert_select 'nav a.nav-link', { text: 'Fairy Helper', count: 1 }
  end

  test 'admins can rank while bidding is closed' do
    SiteSetting.instance.update!(limited_bidding_enabled: false)
    sign_in admins(:admin_one)
    post ranking_path, params: { code: users(:user_one).code }

    assert_response :success
  end
end
