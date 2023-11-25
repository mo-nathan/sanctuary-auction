# frozen_string_literal: true

class AddCategoryToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :category, :string
  end
end
