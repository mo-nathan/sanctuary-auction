# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :item_tags, dependent: :destroy
  has_many :items, through: :item_tags

  validates :name, presence: true, uniqueness: true
  default_scope { order(group: :asc, name: :asc) }
  scope :order_by_group, -> { reorder(group: :asc) }

  def self.groups
    order_by_group.distinct.pluck(:group)
  end
end
