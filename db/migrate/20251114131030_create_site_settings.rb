class CreateSiteSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :site_settings do |t|
      t.boolean :site_enabled, default: true, null: false
      t.datetime :site_enable_time
      t.datetime :site_disable_time
      t.boolean :limited_bidding_enabled, default: true, null: false
      t.datetime :limited_bidding_enable_time
      t.datetime :limited_bidding_disable_time

      t.timestamps
    end

    # Create the single settings row
    reversible do |dir|
      dir.up do
        SiteSetting.create!(
          site_enabled: true,
          limited_bidding_enabled: true
        )
      end
    end
  end
end
