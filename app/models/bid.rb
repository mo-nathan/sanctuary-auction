# frozen_string_literal: true

class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :item

  def join
    amount == 0 ? "0" : "1"
  end
end
