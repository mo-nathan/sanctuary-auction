# frozen_string_literal: true

class AddAuctionToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :auction, :boolean, default: false
  end
end
