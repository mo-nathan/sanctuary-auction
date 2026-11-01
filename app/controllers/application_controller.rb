# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :check_site_access, unless: :skip_site_access_check?

  helper_method :limited_bidding_allowed?, :auction_items?

  private

  def skip_site_access_check?
    admin_signed_in? || devise_controller?
  end

  def check_site_access
    return if SiteSetting.site_accessible?

    redirect_to site_disabled_path
  end

  def limited_bidding_allowed?
    SiteSetting.limited_bidding_allowed?
  end

  def auction_items?
    return @auction_items if defined?(@auction_items)

    @auction_items = Item.auction_items.exists?
  end
end
