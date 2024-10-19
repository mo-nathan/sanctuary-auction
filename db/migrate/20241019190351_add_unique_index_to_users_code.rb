class AddUniqueIndexToUsersCode < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :code, unique: true
  end
end
