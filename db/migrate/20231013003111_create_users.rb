class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :code
      t.string :name
      t.integer :balance, default: 500

      t.timestamps
    end
  end
end
