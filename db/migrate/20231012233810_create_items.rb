class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.text :description
      t.integer :cost
      t.integer :number

      t.timestamps
    end
  end
end
