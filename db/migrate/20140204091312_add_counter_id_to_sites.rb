class AddCounterIdToSites < ActiveRecord::Migration
  def change
    add_column :sites, :counter_id, :string
  end
end
