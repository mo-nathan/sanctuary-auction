# frozen_string_literal: true

class RemoveLoginFromAdmin < ActiveRecord::Migration[7.1]
  def change
    remove_column :admins, :login, :string
  end
end
