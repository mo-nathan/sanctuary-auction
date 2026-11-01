# frozen_string_literal: true

class RankingsController < ApplicationController
  before_action :check_limited_bidding, unless: :admin_signed_in?
  before_action :find_user, only: %i[create update]

  def show; end

  def create
    render :edit
  end

  def update
    @ranking.save(params.permit(item_ids: [])[:item_ids].to_a)
    flash.now.notice = "Saved. #{@user.name} has #{@user.balance} hearts left."
    render :edit
  end

  private

  def check_limited_bidding
    return if SiteSetting.limited_bidding_allowed?

    flash[:alert] = t('bids.limited_bidding_disabled')
    redirect_to root_path
  end

  def find_user
    @user = User.find_by(code: params[:code].to_s.downcase.strip)
    if @user
      @ranking = HeartRanking.new(@user)
    else
      flash[:alert] = "Unable to find a user with the code #{params[:code]}."
      redirect_to ranking_path
    end
  end
end
