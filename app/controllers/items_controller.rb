# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :authenticate_admin!, except: %i[index show]

  def index
    select_items
    @tags = Tag.all # Fetching all tags to show in the filter form
    @selected_tag_ids = params[:tag_ids] || []
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

  def select_items
    @items = Item.all
    params[:tag_ids]&.delete_if(&:empty?)
    return if params[:tag_ids].blank?

    @items = Item.joins(:tags).group('items.id').having('COUNT(tags.id) = ?',
                                                        params[:tag_ids].size).where(tags: { id: params[:tag_ids] })
  end

  def item_params
    params.require(:item).permit(:timing, :host, :description, :cost, :number, :image_url, :auction, :title,
                                 tag_ids: [])
  end
end
