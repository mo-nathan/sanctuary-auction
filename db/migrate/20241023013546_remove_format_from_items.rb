# frozen_string_literal: true

class RemoveFormatFromItems < ActiveRecord::Migration[7.1]
  def change
    remove_column :items, :format, :string
  end
end
