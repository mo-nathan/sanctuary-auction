# frozen_string_literal: true

class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :item

  def join
    amount&.zero? ? '0' : '1'
  end
end
