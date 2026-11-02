# frozen_string_literal: true

# Reads and saves a user's raffle Hearts as a rank order. Unlimited and Auction
# bids aren't part of the ranking, so they and the Hearts they use are left alone.
class HeartRanking
  def initialize(user)
    @user = user
  end

  def ranked_items
    Item.rankable_items.joins(:bids).where(bids: { user_id: @user.id }).where('bids.amount > 0')
        .reorder('bids.amount DESC', 'items.title ASC').preload(:tags)
  end

  def unranked_items
    Item.rankable_items.where.not(id: ranked_items.select('items.id')).preload(:tags)
  end

  # Ranking this many items counts down to 1 Heart with some Hearts to spare,
  # which go 1 at a time to the items ranked below that.
  def self.top_amount(hearts)
    [Integer.sqrt(2 * [hearts, 0].max) - 1, 1].max
  end

  def save(item_ids)
    @user.with_lock do
      bids = @user.bids.where(item: Item.rankable_items)
      hearts = @user.balance + bids.sum(:amount)
      bids.destroy_all
      @user.update!(balance: assign_hearts(item_ids, hearts))
    end
  end

  private

  # Zero amounts get no bid, since ItemSelector can award an item for a bid of 0.
  def assign_hearts(item_ids, hearts)
    top = self.class.top_amount(hearts)
    rankable_items(item_ids).each_with_index do |item, index|
      amount = [top - index, 1].max.clamp(..hearts)
      break unless amount.positive?

      @user.bids.create!(item:, amount:)
      hearts -= amount
    end
    hearts
  end

  def rankable_items(item_ids)
    items = Item.rankable_items.index_by { |item| item.id.to_s }
    item_ids.uniq.filter_map { |id| items[id] }
  end
end
