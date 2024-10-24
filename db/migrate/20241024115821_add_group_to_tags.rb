# frozen_string_literal: true

class AddGroupToTags < ActiveRecord::Migration[7.1]
  def change
    add_column :tags, :group, :string
  end
end
