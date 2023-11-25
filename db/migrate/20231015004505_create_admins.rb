# frozen_string_literal: true

class CreateAdmins < ActiveRecord::Migration[7.1]
  def change
    create_table :admins do |t|
      t.string :login, null: false

      t.timestamps
    end
  end
end
