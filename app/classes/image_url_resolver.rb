# frozen_string_literal: true

require 'net/http'

# Turns a link to an imgur page into a direct link to the image.
class ImageUrlResolver
  IMGUR_HOST = 'imgur.com'
  IMAGE_PAGE = %r{\Ahttps?://(?:www\.)?imgur\.com/(?<id>[A-Za-z0-9]{5,7})(?:[/?#].*)?\z}i
  ALBUM_PAGE = %r{\Ahttps?://(?:www\.)?imgur\.com(?<path>/(?:a|gallery)/[\w-]+)/?(?:[?#].*)?\z}i
  DIRECT_IMAGE = %r{\Ahttps://i\.imgur\.com/\w+\.\w+}
  TIMEOUT = 5
  FETCH_ERRORS = [IOError, SocketError, SystemCallError, Timeout::Error, OpenSSL::SSL::SSLError,
                  Net::ProtocolError].freeze

  def self.resolve(url)
    stripped = url.to_s.strip
    if (match = IMAGE_PAGE.match(stripped))
      "https://i.imgur.com/#{match[:id]}.jpeg"
    elsif (match = ALBUM_PAGE.match(stripped))
      album_image(match[:path]) || url
    else
      url
    end
  end

  def self.album_image(path)
    response = fetch(path)
    return unless response.is_a?(Net::HTTPSuccess)

    Nokogiri::HTML(response.body).at_css('meta[property="og:image"]')&.[]('content').to_s[DIRECT_IMAGE]
  rescue *FETCH_ERRORS => e
    Rails.logger.warn { "Unable to look up imgur album #{path}: #{e.message}" }
    nil
  end
  private_class_method :album_image

  # Always connects to imgur, whatever URL was entered
  def self.fetch(path)
    Net::HTTP.start(IMGUR_HOST, 443, use_ssl: true, open_timeout: TIMEOUT, read_timeout: TIMEOUT) do |http|
      http.get(path)
    end
  end
  private_class_method :fetch
end
