# frozen_string_literal: true

class SiteSetting < ApplicationRecord
  # Singleton pattern - only one settings record should exist
  validates :site_enabled, inclusion: { in: [true, false] }
  validates :limited_bidding_enabled, inclusion: { in: [true, false] }

  def self.instance
    first_or_create!(
      site_enabled: true,
      limited_bidding_enabled: true
    )
  end

  # Check if the site is accessible to non-admins
  # Logic: scheduled times override the manual toggle
  def self.site_accessible?
    settings = instance
    current_time = Time.current

    # If we have a disable_time and it has passed, site is disabled
    return false if settings.site_disable_time.present? && current_time >= settings.site_disable_time

    # If we have an enable_time and it hasn't passed yet, site is disabled
    return false if settings.site_enable_time.present? && current_time < settings.site_enable_time

    # If we have an enable_time and it HAS passed, site is enabled (scheduled enable occurred)
    return true if settings.site_enable_time.present? && current_time >= settings.site_enable_time

    # Otherwise, use the manual toggle
    settings.site_enabled
  end

  # Check if bidding on limited items is allowed
  # Logic: scheduled times override the manual toggle
  def self.limited_bidding_allowed?
    settings = instance
    current_time = Time.current

    # If we have a disable_time and it has passed, bidding is disabled
    if settings.limited_bidding_disable_time.present? && current_time >= settings.limited_bidding_disable_time
      return false
    end

    # If we have an enable_time and it hasn't passed yet, bidding is disabled
    return false if settings.limited_bidding_enable_time.present? && current_time < settings.limited_bidding_enable_time

    # If we have an enable_time and it HAS passed, bidding is enabled (scheduled enable occurred)
    return true if settings.limited_bidding_enable_time.present? && current_time >= settings.limited_bidding_enable_time

    # Otherwise, use the manual toggle
    settings.limited_bidding_enabled
  end

  # Get the next time the site will be enabled (for display)
  def self.next_site_enable_time
    settings = instance
    return nil if settings.site_enable_time.blank?
    return nil if Time.current >= settings.site_enable_time

    settings.site_enable_time
  end

  # Get the next time limited bidding will be enabled (for display)
  def self.next_limited_bidding_enable_time
    settings = instance
    return nil if settings.limited_bidding_enable_time.blank?
    return nil if Time.current >= settings.limited_bidding_enable_time

    settings.limited_bidding_enable_time
  end
end
