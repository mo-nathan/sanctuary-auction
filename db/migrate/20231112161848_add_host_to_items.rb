# frozen_string_literal: true

class AddHostToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :host, :string
  end
end
