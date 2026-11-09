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
    assert_includes(response.body, 'The kinds of items below each work a little')
  end

  test 'hides auction tab and text when there are no auction items' do
    Item.auction_items.destroy_all
    get welcome_index_url
    assert_select 'a.nav-link', text: 'Auction', count: 0
    assert_select 'h2', text: 'Auction:', count: 0
    assert_select 'a[href=?]', '/items?type=Auction', count: 0
    assert_not_includes(response.body, 'auction items')
    assert_not_includes(response.body, 'auctioned live')
  end

  test 'describes raffle items with a link to their tab' do
    get welcome_index_url
    assert_select 'a[href=?]', '/items', text: 'Raffle Items:'
    assert_includes(response.body, 'Raffle winners will be drawn after the')
  end

  test 'describes the unlimited tab when there are unlimited items' do
    get welcome_index_url
    assert_select 'a.nav-link', text: 'Unlimited Items'
    assert_select 'a[href=?]', '/items?type=Unlimited', text: 'Unlimited Items:'
    assert_includes(response.body, 'no participation limit')
    assert_includes(response.body, 'check the "Get One" box')
  end

  test 'orders the item sections like the tabs' do
    get welcome_index_url
    assert_equal(['Home', 'Unlimited Items', 'Raffle Items', 'Auction', 'Fairy Helper', 'Users'],
                 css_select('a.nav-link').map(&:text))
    assert_operator(response.body.index('Unlimited Items:'), :<,
                    response.body.index('Raffle Items:</a>'))
  end

  test 'states the unlimited cost when every unlimited item costs the same' do
    Item.unlimited_items.each { |item| item.update!(cost: 25) }
    get welcome_index_url
    assert_includes(response.body, 'Each one costs 25 hearts.')
    assert_not_includes(response.body, 'They cost between')
  end

  test 'states a range when unlimited items cost different amounts' do
    Item.unlimited_items.each { |item| item.update!(cost: 25) }
    Item.create!(title: 'Cheap Unlimited Item', cost: 5)
    get welcome_index_url
    assert_includes(response.body, 'They cost between 5 and')
    assert_includes(response.body, '25 hearts, as shown on each listing.')
    assert_not_includes(response.body, 'Each one costs')
  end

  test 'hides unlimited text when there are no unlimited items' do
    Item.unlimited_items.destroy_all
    get welcome_index_url
    assert_select 'a.nav-link', text: 'Unlimited Items', count: 0
    assert_select 'a[href=?]', '/items?type=Unlimited', count: 0
    assert_not_includes(response.body, 'unlimited items')
    assert_not_includes(response.body, 'Get One')
  end

  test 'announces the fairy helper as new, in the section after the items' do
    get welcome_index_url
    assert_select 'p', text: /\A\s*New this year, the Fairy Helper is a\s+tool for spending your hearts/
    assert_operator(response.body.index('Auction:</a>'), :<,
                    response.body.index('New this year'))
    intro = response.body[%r{As a participant.*?</p>}m]
    assert_not_includes(intro, 'Fairy')
    assert_select 'p a[href=?]', ranking_path, { count: 1, text: 'Fairy Helper' }
    assert_select 'p b a[href=?]', ranking_path, count: 0
  end

  test 'leaves the fairy helper out of the intro when bidding is closed' do
    SiteSetting.instance.update!(limited_bidding_enabled: false)
    get welcome_index_url
    assert_includes(response.body, 'The kinds of items below each work a little')
    assert_not_includes(response.body, 'New this year')
  end

  test 'describes the fairy helper while bidding is open' do
    get welcome_index_url
    assert_select 'p a[href=?]', ranking_path, text: 'Fairy Helper'
    assert_includes(response.body, 'Auction Fairy spread your hearts')
    assert_includes(response.body, 'hearts are spread across your list')
  end

  test 'hides fairy helper text when bidding is closed' do
    SiteSetting.instance.update!(limited_bidding_enabled: false)
    get welcome_index_url
    assert_select 'a[href=?]', ranking_path, count: 0
    assert_not_includes(response.body, 'Fairy Helper')
    assert_includes(response.body, 'One way to do this is to start by going through')
    assert_includes(response.body, 'Raffle items are not currently available for entering hearts.')
  end

  test 'shows the earlier of the bidding and site disable times as the raffle deadline' do
    travel_to Time.zone.parse('2026-11-13 10:00') do
      SiteSetting.instance.update!(site_disable_time: Time.zone.parse('2026-11-15 23:59'),
                                   limited_bidding_disable_time: Time.zone.parse('2026-11-15 15:00'))
      get welcome_index_url
      assert_includes(response.body, 'Raffle items are available for entering hearts until')
      assert_select 'p b', text: 'Sunday, November 15 at 3:00 PM EST'
      assert_includes(response.body, 'tab stay open until')
      assert_select 'p b', text: 'Sunday, November 15 at 11:59 PM EST'
    end
  end

  test 'uses the site disable time when bidding is scheduled to outlast the site' do
    travel_to Time.zone.parse('2026-11-13 10:00') do
      SiteSetting.instance.update!(site_disable_time: Time.zone.parse('2026-11-15 23:59'),
                                   limited_bidding_disable_time: Time.zone.parse('2026-11-16 15:00'))
      get welcome_index_url
      assert_select 'p b', { text: 'Sunday, November 15 at 11:59 PM EST', count: 2 }
      assert_select 'p b', { text: 'Monday, November 16 at 3:00 PM EST', count: 0 }
      assert_includes(response.body, 'tab stay open until')
      assert_not_includes(response.body, 'can still go there')
    end
  end

  test 'announces when entering hearts opens while it is still scheduled' do
    travel_to Time.zone.parse('2026-11-08 19:00') do
      SiteSetting.instance.update!(limited_bidding_enabled: false,
                                   limited_bidding_enable_time: Time.zone.parse('2026-11-10 09:00'),
                                   limited_bidding_disable_time: Time.zone.parse('2026-11-15 23:59'),
                                   site_disable_time: Time.zone.parse('2026-11-15 23:59'))
      get welcome_index_url
      assert_includes(response.body, 'Entering hearts on raffle items opens')
      assert_select 'p b', text: 'Tuesday, November 10 at 9:00 AM EST'
      assert_includes(response.body, 'and closes')
      assert_select 'p b', { text: 'Sunday, November 15 at 11:59 PM EST', count: 2 }
      assert_not_includes(response.body, 'not currently available')
    end
  end

  test 'points at the site closing time once raffle entries have closed' do
    travel_to Time.zone.parse('2026-11-13 10:00') do
      SiteSetting.instance.update!(limited_bidding_enabled: false,
                                   site_disable_time: Time.zone.parse('2026-11-15 23:59'))
      get welcome_index_url
      assert_includes(response.body, 'Raffle items are not currently available for entering hearts.')
      assert_includes(response.body, 'tab stay open until')
      assert_select 'p b', text: 'Sunday, November 15 at 11:59 PM EST'
      assert_not_includes(response.body, 'Entering hearts on raffle items opens')
    end
  end

  test 'names the time raffle entries closed once it has passed' do
    travel_to Time.zone.parse('2026-11-15 20:00') do
      SiteSetting.instance.update!(limited_bidding_disable_time: Time.zone.parse('2026-11-15 15:00'),
                                   site_disable_time: Time.zone.parse('2026-11-15 23:59'))
      get welcome_index_url
      assert_includes(response.body, 'Raffle items closed for entering hearts on')
      assert_select 'p b', text: 'Sunday, November 15 at 3:00 PM EST'
      assert_select 'p b', text: 'Sunday, November 15 at 11:59 PM EST'
      assert_includes(response.body, 'can still go there')
      assert_not_includes(response.body, 'not currently available')
    end
  end

  test 'describes the deadlines generically when nothing is scheduled' do
    get welcome_index_url
    assert_includes(response.body, 'entering hearts until the event is')
    assert_includes(response.body, 'tab stay open for as long as the')
  end

  test 'always refers to the whole event as the event' do
    Item.auction_items.destroy_all
    get welcome_index_url
    assert_includes(response.body, 'As a participant in the event')
    assert_includes(response.body, 'will be drawn after the')
    assert_includes(response.body, 'for entering hearts until')
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
