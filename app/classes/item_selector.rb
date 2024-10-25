# frozen_string_literal: true

class ItemSelector
  def initialize
    @max_bid = 0
    @least_total = nil
    @items = []
  end

  def consider(bid)
    @bid_total = total_bids(bid.item)
    if bid.amount > @max_bid
      wins(bid)
    elsif bid.amount == @max_bid
      if @least_total.nil? || @bid_total < @least_total
        wins(bid)
      elsif @bid_total == @least_total
        @items.append(bid.item)
      end
    end
  end

  def sample
    @items.sample
  end

  private

  def total_bids(item)
    total = 0
    item.bids.find_each do |bid|
      total += bid.amount
    end
    total
  end

  def wins(bid)
    @max_bid = bid.amount
    @least_total = @bid_total
    @items = [bid.item]
  end
end
