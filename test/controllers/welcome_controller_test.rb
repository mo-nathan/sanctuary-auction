# frozen_string_literal: true

require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get welcome_index_url
    assert_response :success
  end

  test 'layout declares the language and labels the logo link' do
    get welcome_index_url
    assert_select 'html[lang=en]'
    assert_select 'a[href=?] img[alt=?]', root_path, 'The Sanctuary Boston, home'
  end

  test 'shows auction tab and text when there are auction items' do
    get welcome_index_url
    assert_select 'a.nav-link', text: 'Auction'
    assert_select 'h2', text: 'Auction:'
    assert_select 'a[href=?]', '/items?type=Auction', text: 'Auction:'
    assert_includes(response.body, 'between raffle and auction items')
  end

  test 'hides auction tab and text when there are no auction items' do
    Item.auction_items.destroy_all
    get welcome_index_url
    assert_select 'a.nav-link', text: 'Auction', count: 0
    assert_select 'h2', text: 'Auction:', count: 0
    assert_select 'a[href=?]', '/items?type=Auction', count: 0
    assert_not_includes(response.body, 'auction items')
    assert_includes(response.body, 'on raffle items.')
  end

  test 'always refers to the whole event as the event' do
    Item.auction_items.destroy_all
    get welcome_index_url
    assert_includes(response.body, 'As a participant in the event')
    assert_includes(response.body, 'After the event')
    assert_includes(response.body, 'unavailable for bidding after 3 pm')
  end

  test 'layout has landmarks, a page title, and a top heading' do
    get welcome_index_url
    assert_select 'title', 'Home | Anti-Capitalist Community Auction'
    assert_select 'header img'
    assert_select 'main nav[aria-label=Site] ul.nav-tabs'
    assert_select 'main h1', 1
    assert_select 'footer'
  end

  test 'home page nests its sub-list inside a list item' do
    get welcome_index_url
    assert_select 'ul > ul', 0
    assert_select 'ul > li > ul'
  end
end
