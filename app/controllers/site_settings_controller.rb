# frozen_string_literal: true

class SiteSettingsController < ApplicationController
  before_action :authenticate_admin!

  def show
    @site_setting = SiteSetting.instance
  end

  def update
    @site_setting = SiteSetting.instance

    if @site_setting.update(processed_site_setting_params)
      redirect_to site_settings_path, notice: t('site_settings.update_success')
    else
      render :show, status: :unprocessable_content
    end
  end

  private

  def processed_site_setting_params
    raw_params = params[:site_setting]
    {
      site_enabled: raw_params[:site_enabled],
      limited_bidding_enabled: raw_params[:limited_bidding_enabled]
    }.merge(parse_datetime_fields(raw_params))
  end

  def parse_datetime_fields(raw_params)
    datetime_fields = %w[site_enable_time site_disable_time
                         limited_bidding_enable_time limited_bidding_disable_time]

    datetime_fields.each_with_object({}) do |field, result|
      result[field] = Time.zone.parse(raw_params[field]) if raw_params[field].present?
    end
  end
end
