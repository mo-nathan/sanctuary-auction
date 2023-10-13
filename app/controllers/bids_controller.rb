# frozen_string_literal: true

class BidsController < ApplicationController
  def create
    @item = Item.find(params[:item_id])
    @user = User.find_by(code: params[:bid][:code])
    amount = params[:bid][:amount]
    if @user.deduct(amount)
      @bid = @item.bids.create(user: @user, amount:)
    else
      flash.alert = "#{@user.name} does not have enough Sanctuary Boston Bucks"
    end
    redirect_to item_path(@item)
  end
end
