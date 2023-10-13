# frozen_string_literal: true

class BidsController < ApplicationController
  def create
    @item = Item.find(params[:item_id])
    @user = User.find_by(code: params[:bid][:code])
    @bid = @item.bids.create(user: @user, amount: params[:bid][:amount])
    redirect_to item_path(@item)
  end

  private

  def bid_params
    params.require(:bid).permit(:code, :amount)
  end
end
