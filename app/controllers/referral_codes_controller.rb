class ReferralCodesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def generate
    while @referral_code.blank?
      code = Digest::SHA2.new.hexdigest(Time.now.to_f.to_s)[0..7]

      unless ReferralCode.where(code: code).exists?
        @referral_code = ReferralCode.create! code: code
      end
    end

    render :json => @referral_code
  end
end
