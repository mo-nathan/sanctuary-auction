# frozen_string_literal: true

class Item < ApplicationRecord
  has_many :bids
  validates :title, presence: true
  validate :cost_or_number
  default_scope { order(title: :asc) }

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
                 'must be a positive number or cost must be a positive number of Sanctuary Bucks, but not both')
    end
  end
end
