class Site < ActiveRecord::Base
  belongs_to :referral_code

  validates :domain, :presence => true, :format => { with: /\A[a-z\-\.0-9]+\z/i }, :uniqueness => true
  validates :referral_code, :presence => true
  validates :referral_code_id, :uniqueness => true

  scope :popular, lambda { order("rating DESC") }

  def referral=(code)
    self.referral_code = ReferralCode.find_by(code: code)
  end

  def referral
    referral_code.try(:code)
  end

  def url
    "http://#{domain}"
  end
end
