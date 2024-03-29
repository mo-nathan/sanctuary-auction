# frozen_string_literal: true

class AddImageStringToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :image_url, :string
  end
end
