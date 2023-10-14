# frozen_string_literal: true

class BidsController < ApplicationController
  def create
    @item = Item.find(params[:item_id])
    @user = User.find_by(code: params[:bid][:code])
    if @user
      delete_old_bid(@item, @user)
      deduct(params[:bid][:amount].to_i)
    else
      flash.alert = "Unable to find a user with the code #{params[:bid][:code]}"
    end
    redirect_to item_path(@item)
  end

  private

  def delete_old_bid(item, user)
    bid = Bid.find_by(item:, user:)
    return unless bid

    user.balance += bid.amount
    bid.delete
  end

  def deduct(amount)
    if @user.deduct(amount)
      @bid = @item.bids.create(user: @user, amount:) if amount.positive?
    else
      flash.alert = "#{@user.name} only has #{@user.balance} Sanctuary Boston Bucks"
    end
  end
end
