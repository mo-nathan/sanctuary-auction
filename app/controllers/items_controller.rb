# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :authenticate_admin!, except: %i[index show]

  def index
    @tags = Tag.all # Fetching all tags to show in the filter form
    @type = calc_type
    select_items
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

  def calc_type
    return params[:type] if params[:type]

    # return 'Auction' if params[:tag_ids]&.include?(auction_id)

    'raffle'
  end

  def select_items
    @items = if @type == 'Auction'
               Item.where(auction: true)
             else
               Item.where(auction: false)
             end
    # add_type_tag
    return if blank_params?

    @items = Item.joins(:tags).group('items.id').having('COUNT(tags.id) = ?',
                                                        params[:tag_ids].size).where(tags: { id: params[:tag_ids] })
  end

  def blank_params?
    params[:tag_ids]&.delete_if(&:empty?)
    params[:tag_ids].blank?
  end

  # def add_type_tag
  #   return unless @type == 'Auction' && auction_id

  #   if params[:tag_ids]
  #     params[:tag_ids].append(auction_id) unless params[:tag_ids].include?(auction_id)
  #   else
  #     params[:tag_ids] = [auction_id]
  #   end
  # end

  # def auction_id
  #   tag = Tagger.auction_tag
  #   return nil unless tag

  #   @auction_id ||= tag.id.to_s
  # end

  def item_params
    params.require(:item).permit(:timing, :host, :description, :cost, :number, :image_url, :auction, :title,
                                 tag_ids: [])
  end
end
