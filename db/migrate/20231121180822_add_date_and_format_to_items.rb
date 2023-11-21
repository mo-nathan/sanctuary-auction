class AddDateAndFormatToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :event_date, :date
    add_column :items, :format, :string
  end
end
