# frozen_string_literal: true

class AddTitleToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :title, :string, null: false, default: "An Item"
  end
end
