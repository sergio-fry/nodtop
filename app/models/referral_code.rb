class ReferralCode < ActiveRecord::Base
  validates :code, :presence => true, :format => { with: /\A[a-f0-9]+\z/i }
end
