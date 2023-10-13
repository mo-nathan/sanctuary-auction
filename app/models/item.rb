class Item < ApplicationRecord
  validates :description, presence: true
end
