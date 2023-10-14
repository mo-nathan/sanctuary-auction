# frozen_string_literal: true

class Item < ApplicationRecord
  has_many :bids
  validates :description, presence: true

  def total
    result = 0
    bids.each do |bid|
      result += bid.amount
    end
    result
  end
end
