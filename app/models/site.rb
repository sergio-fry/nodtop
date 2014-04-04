require "net/http"
require "uri"

class Site < ActiveRecord::Base
  belongs_to :referral_code
  serialize :google_data

  validates :domain, :presence => { :message => "Домен не может быть пустым" }, :format => { with: /\A[a-z\-\.0-9]+\z/i, :message => "Некорректный формат домена" }, :uniqueness => { :message => "Этот сайт уже есть в рейтинге" }
  #validates :referral_code, :presence => true
  #validates :referral_code_id, :uniqueness => true

  before_create :set_counter_id
  after_create lambda { delay.update_rating }

  scope :popular, lambda { where("rating > 0").order("rating DESC") }
  scope :zero_rating, lambda { where("rating = 0") }

  def referral=(code)
    self.referral_code = ReferralCode.find_by(code: code)
  end

  def referral
    referral_code.try(:code)
  end

  def url
    "http://#{domain}"
  end

  def update_banners
    bucket = AWS_STORE.directories.get ENV['S3_BUCKET_NAME']
    bucket.files.create(:key => "banners/#{counter_id}/banner_1.gif", :body => BannerGenerator.generate(rank || (Site.maximum(:rank) + 1), BannerGenerator::TYPE_BLACK), :public => true)
    bucket.files.create(:key => "banners/#{counter_id}/banner_2.gif", :body => BannerGenerator.generate(rank || (Site.maximum(:rank) + 1), BannerGenerator::TYPE_ORANGE), :public => true)
  end

  def update_metrics
    Metric.add_data_point("Site:#{id}:rating", Time.now, rating || 0)
    Metric.add_data_point("Site:#{id}:rank", Time.now, rank || (Site.maximum(:rank) || 0) + 1)
  end

  def update_rating
    uri = URI.parse("https://www.googleapis.com/urlshortener/v1/url?shortUrl=http://goo.gl/#{counter_id}&projection=FULL")

    response = Net::HTTP.get_response(uri)
    data_hash = JSON.parse(response.body)

    self.google_data = data_hash

    self.rating = (data_hash["analytics"]["week"]["longUrlClicks"].to_f / 100.0).round(2)
    self.checked_at = Time.now

    save!
  end

  private

  def set_counter_id
    url = "https://www.googleapis.com/urlshortener/v1/url"
    uri = URI(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = '{"longUrl": "http://sergio-fry.github.io/nodtop-counter-site/counter/v1/Ya-lublu-Rossiu.gif?ref=' + domain + '"}'
    request["Content-Type"] = "application/json"
    response = http.request(request)

    self.counter_id = JSON.parse(response.body)["id"].sub(/\Ahttp:\/\/goo.gl\//, "")
  end
end
