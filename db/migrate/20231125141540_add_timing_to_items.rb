# frozen_string_literal: true

class AddTimingToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :timing, :string
    Item.where.not(event_date: nil).each do |item|
      item.timing = item.event_date.strftime('%B %e')
    end
  end
end
