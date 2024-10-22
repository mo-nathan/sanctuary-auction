# frozen_string_literal: true

class Item < ApplicationRecord
  has_many :bids, dependent: :destroy
  has_many :item_tags, dependent: :destroy
  has_many :tags, through: :item_tags
  validates :title, presence: true
  validate :cost_or_number
  default_scope { order(title: :asc) }
  scope :buy_in_items, -> { where.not(cost: nil) }
  scope :raffle_items, -> { where('cost IS NULL AND NOT auction') }
  scope :auction_items, -> { where('cost IS NULL AND auction') }

  def self.selected(type)
    by_type(type)
  end

  def self.by_type(type)
    if type == 'Buy-In'
      buy_in_items
    elsif type == 'Auction'
      auction_items
    else
      raffle_items
    end
  end

  def total
    result = 0
    bids.each do |bid|
      result += bid.amount
    end
    result
  end

  def cost_or_number
    number_positive = number.to_i.positive?
    cost_positive = cost.to_i.positive?
    unless (cost.nil? && number_positive) ||
           (number.nil? && cost_positive)
      errors.add(:number,
                 'must be a positive number or cost must be a positive number of Tickets, but not both')
    end
  end

  def item_type
    if cost.nil?
      auction ? 'Auction' : 'Raffle'
    else
      'Buy-In'
    end
  end
end
