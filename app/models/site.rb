require "net/http"
require "uri"

class Site < ActiveRecord::Base
  belongs_to :referral_code

  validates :domain, :presence => true, :format => { with: /\A[a-z\-\.0-9]+\z/i }, :uniqueness => true
  validates :referral_code, :presence => true
  validates :referral_code_id, :uniqueness => true

  before_create :set_counter_id

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

  private

  def set_counter_id
    url = "https://www.googleapis.com/urlshortener/v1/url"
    uri = URI(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = '{"longUrl": "http://rusnod.github.io/lenta/javascripts/lenta.min.js?ref=' + domain + '"}'
    request["Content-Type"] = "application/json"
    response = http.request(request)

    self.counter_id = JSON.parse(response.body)["id"].sub(/\Ahttp:\/\/goo.gl\//, "")
  end
end
