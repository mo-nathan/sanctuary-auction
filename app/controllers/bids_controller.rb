# frozen_string_literal: true

class BidsController < ApplicationController
  def create
    @item = Item.find(params[:item_id])
    @user = User.find_by(code: params[:bid][:code].downcase.strip)
    update_user(@item, @user)
    redirect_to item_path(@item)
  end

  private

  def update_user(item, user)
    if user
      update_balance(item, user, item.bids.find_by(user:), calc_amount(item))
    else
      flash.alert = "Unable to find a user with the code #{params[:bid][:code]}"
    end
  end

  def update_balance(item, user, bid, amount)
    balance = calc_balance(user, bid, amount)
    if balance >= 0
      user.balance = balance
      user.save
      make_bid(item, user, bid, amount)
    else
      flash.alert = "Cannot make update. #{user.name} has #{user.balance} tickets left."
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

  def make_bid(item, user, bid, amount)
    if bid
      if amount.zero?
        bid.destroy
      else
        bid.amount = amount
        bid.save
      end
    else
      item.bids.create(user:, amount:)
    end
  end
end
