# frozen_string_literal: true

class RemoveEventDateFromItems < ActiveRecord::Migration[7.1]
  def change
    remove_column :items, :event_date, :date
  end
end
