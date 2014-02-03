class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :title
      t.string :domain
      t.float :rating, :default => 0
      t.string :referral_code_id

      t.timestamps
    end
  end
end
