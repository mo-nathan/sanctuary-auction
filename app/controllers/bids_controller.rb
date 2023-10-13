# frozen_string_literal: true

class BidsController < ApplicationController
  def create
    @item = Item.find(params[:item_id])
    @user = User.find_by(code: params[:bid][:code])
    deduct(params[:bid][:amount].to_i)
    redirect_to item_path(@item)
  end

  private

  def deduct(amount)
    if @user.deduct(amount)
      @bid = @item.bids.create(user: @user, amount:)
    else
      flash.alert = "#{@user.name} only has #{@user.balance} Sanctuary Boston Bucks"
    end
  end
end
