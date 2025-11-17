# frozen_string_literal: true

class BidsController < ApplicationController
  before_action :check_limited_bidding, unless: :admin_signed_in?

  def create
    @item = Item.find(params[:item_id])
    @user = User.find_by(code: params[:bid][:code].downcase.strip)
    update_user(@item, @user)
    redirect_to item_path(@item)
  end

  private

  def check_limited_bidding
    @item = Item.find(params[:item_id])

    # Allow unlimited items (items with cost) regardless of limited bidding status
    return if @item.cost.present?

    # Check if limited bidding is allowed for items with number (raffle/auction)
    return if SiteSetting.limited_bidding_allowed?

    # Bidding is not allowed
    flash[:alert] = t('bids.limited_bidding_disabled')
    redirect_to item_path(@item)
  end

  def update_user(item, user)
    return if bad_amount?(user)

    if user
      update_balance(item, user, item.bids.find_by(user:), calc_amount(item))
    else
      flash.alert = "Unable to find a user with the code #{params[:bid][:code]}."
    end
  end

  def update_balance(item, user, bid, amount)
    balance = calc_balance(user, bid, amount)
    if balance >= 0
      user.balance = balance
      user.save
      make_bid(item, user, bid, amount)
      flash.notice = "#{user.name} has #{user.balance} hearts left."
    else
      flash.alert = "Cannot make update. #{user.name} has #{user.balance} hearts left."
    end
  end

  def calc_balance(user, bid, amount)
    balance = user.balance - amount
    balance += bid.amount if bid
    balance
  end

  def calc_amount(item)
    return params[:bid][:amount].to_i unless item.cost

    # item.cost * amount
    if params[:bid][:join] == '0'
      0
    else
      item.cost
    end
  end

  def bad_amount?(user)
    amount = params[:bid][:amount]
    if amount == ''
      flash.alert = "Cannot have an empty bid.  #{user.name} has #{user.balance} hearts left."
      true
    elsif amount.to_i.negative?
      flash.alert = "Amount cannot be less than 0.  #{user.name} has #{user.balance} hearts left."
      true
    else
      false
    end
  end

  def make_bid(item, user, bid, amount)
    if bid
      if amount.zero?
        bid.destroy
      else
        bid.amount = amount
        bid.save
      end
    elsif amount.positive?
      item.bids.create(user:, amount:)
    end
  end
end
