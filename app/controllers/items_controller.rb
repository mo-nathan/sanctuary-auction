# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :authenticate_admin!, except: %i[index show]

  def index
    @type = params[:type] || 'Raffle'
    @filter = params[:filter] || 'All'
    @items = Item.selected(@type, @filter)
  end

  def show
    @item = Item.find(params[:id])
  end

  def new
    @item = Item.new
  end

  def edit
    @item = Item.find(params[:id])
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      redirect_to @item
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @item = Item.find(params[:id])

    if @item.update(item_params)
      redirect_to @item
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    redirect_to root_path, status: :see_other
  end

  private

  def item_params
    params.require(:item).permit(:format, :timing, :category, :host, :description,
                                 :cost, :number, :image_url, :auction, :title)
  end
end
