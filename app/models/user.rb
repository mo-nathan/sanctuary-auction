# frozen_string_literal: true

class User < ApplicationRecord
  has_many :bids, dependent: :destroy
  has_many :items, through: :bids
  validates :code, presence: true
  validates :code, uniqueness: true
  validates :name, presence: true
  default_scope { order(name: :asc) }
end
