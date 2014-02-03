class CreateReferralCodes < ActiveRecord::Migration
  def change
    create_table :referral_codes do |t|
      t.string :code
      t.integer :parent_id

      t.timestamps
    end
  end
end
