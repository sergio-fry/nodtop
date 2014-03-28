class AddRankToSites < ActiveRecord::Migration
  def change
    add_column :sites, :rank, :integer
  end
end
