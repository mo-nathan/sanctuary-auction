# frozen_string_literal: true

class RemoveCategoryFromItems < ActiveRecord::Migration[7.1]
  def change
    remove_column :items, :category, :string
  end
end
