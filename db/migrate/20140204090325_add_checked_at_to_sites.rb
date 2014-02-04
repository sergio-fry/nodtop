class AddCheckedAtToSites < ActiveRecord::Migration
  def change
    add_column :sites, :checked_at, :datetime
  end
end
