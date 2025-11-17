# frozen_string_literal: true

class SiteDisabledController < ApplicationController
  skip_before_action :check_site_access

  def index
    redirect_to root_path if SiteSetting.site_accessible?

    @next_enable_time = SiteSetting.next_site_enable_time
  end
end
