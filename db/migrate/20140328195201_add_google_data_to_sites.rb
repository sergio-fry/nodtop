class AddGoogleDataToSites < ActiveRecord::Migration
  def change
    add_column :sites, :google_data, :text
  end
end
