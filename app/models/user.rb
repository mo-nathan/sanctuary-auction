# frozen_string_literal: true

class User < ApplicationRecord
  has_many :bids
  validates :code, presence: true
  validates :name, presence: true

  def deduct(amount)
    safe_amount = amount.to_i
    return false if balance < safe_amount
    return false if safe_amount <= 0

    self.balance -= amount.to_i
    save
  end
end
