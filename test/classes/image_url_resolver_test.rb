# frozen_string_literal: true

require 'test_helper'

class ImageUrlResolverTest < ActiveSupport::TestCase
  ALBUM_URL = 'https://imgur.com/a/Ym2upoL'

  def stub_album_page(html)
    response = Net::HTTPOK.new('1.1', '200', 'OK')
    response.stubs(:body).returns(html)
    http = mock('http')
    http.expects(:get).with('/a/Ym2upoL').returns(response)
    Net::HTTP.expects(:start).with('imgur.com', 443, anything).yields(http).returns(response)
  end

  test 'rewrites image pages without using the network' do
    Net::HTTP.expects(:start).never
    assert_equal('https://i.imgur.com/hkiJR5W.jpeg', ImageUrlResolver.resolve('https://imgur.com/hkiJR5W'))
    assert_equal('https://i.imgur.com/hkiJR5W.jpeg', ImageUrlResolver.resolve('http://www.imgur.com/hkiJR5W/'))
    assert_equal('https://i.imgur.com/hkiJR5W.jpeg', ImageUrlResolver.resolve(" https://imgur.com/hkiJR5W\n"))
  end

  test 'leaves other URLs alone without using the network' do
    Net::HTTP.expects(:start).never
    ['https://i.imgur.com/hkiJR5W.jpeg', 'https://example.com/hkiJR5W', 'https://imgur.com.evil.example/a/abc',
     'https://drive.google.com/file/d/abc/view', ''].each do |url|
      assert_equal(url, ImageUrlResolver.resolve(url))
    end
    assert_nil(ImageUrlResolver.resolve(nil))
  end

  test 'finds the image for an album' do
    stub_album_page('<meta property="og:image" content="https://i.imgur.com/wp1XSFR.jpeg?fb">')
    assert_equal('https://i.imgur.com/wp1XSFR.jpeg', ImageUrlResolver.resolve(ALBUM_URL))
  end

  test 'keeps the album URL when the page has no image' do
    stub_album_page('<html></html>')
    assert_equal(ALBUM_URL, ImageUrlResolver.resolve(ALBUM_URL))
  end

  test 'keeps the album URL when the image is not hosted on imgur' do
    stub_album_page('<meta property="og:image" content="https://example.com/image.jpeg">')
    assert_equal(ALBUM_URL, ImageUrlResolver.resolve(ALBUM_URL))
  end

  test 'keeps the album URL when the request is unsuccessful' do
    Net::HTTP.expects(:start).returns(Net::HTTPNotFound.new('1.1', '404', 'Not Found'))
    assert_equal(ALBUM_URL, ImageUrlResolver.resolve(ALBUM_URL))
  end

  test 'keeps the album URL when the lookup fails' do
    Net::HTTP.expects(:start).raises(Net::OpenTimeout)
    assert_equal(ALBUM_URL, ImageUrlResolver.resolve(ALBUM_URL))
  end
end
