# frozen_string_literal: true

class BidsController < ApplicationController
  def create
    @item = Item.find(params[:item_id])
    @user = User.find_by(code: params[:bid][:code])
    update_user(@item, @user)
    redirect_to item_path(@item)
  end

  private

  def update_user(item, user)
    if user
      delete_old_bid(item, user)
      deduct(item, user, params[:bid][:amount].to_i)
    else
      flash.alert = "Unable to find a user with the code #{params[:bid][:code]}"
    end
  end

  def delete_old_bid(item, user)
    bid = Bid.find_by(item:, user:)
    return unless bid

    user.balance += bid.amount
    bid.delete
  end

  def deduct(item, user, amount)
    if user.deduct(amount)
      item.bids.create(user:, amount:) if amount.positive?
    else
      flash.alert = "#{user.name} only has #{user.balance} Sanctuary Boston Bucks"
    end
  end
end
