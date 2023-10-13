class Item < ApplicationRecord
  has_many :bids
  validates :description, presence: true
end
