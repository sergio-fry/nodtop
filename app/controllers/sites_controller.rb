require "net/http"
require "uri"

class SitesController < ApplicationController
  before_action :set_site, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, :only => [:check_all, :update_banners]

  # GET /sites
  # GET /sites.json
  def index
    @sites = Site.all
  end

  # GET /sites/1
  # GET /sites/1.json
  def show
  end

  # GET /sites/new
  def new
    referral_code = ReferralCode.find_by(code: params[:referral])

    @site = Site.new(:referral_code => referral_code)
  end

  # GET /sites/1/edit
  def edit
  end

  # POST /sites
  # POST /sites.json
  def create
    @site = Site.new(site_params)

    session[:referral] = @site.referral

    respond_to do |format|
      if @site.save
        format.html { redirect_to @site, notice: 'Site was successfully created.' }
        format.json { render action: 'show', status: :created, location: @site }
      else
        format.html { render action: 'new' }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sites/1
  # PATCH/PUT /sites/1.json
  def update
    respond_to do |format|
      if @site.update(site_params)
        format.html { redirect_to sites_url, notice: 'Site was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    @site.destroy
    respond_to do |format|
      format.html { redirect_to sites_url }
      format.json { head :no_content }
    end
  end

  def check_all
    Site.where("checked_at IS NULL OR checked_at < ?", 1.hour.ago).each do |site|
      uri = URI.parse("https://www.googleapis.com/urlshortener/v1/url?shortUrl=http://goo.gl/#{site.counter_id}&projection=FULL")

      response = Net::HTTP.get_response(uri)

      Rails.logger.debug(response.body)

      data_hash = JSON.parse(response.body)
      
      site.rating = (data_hash["analytics"]["week"]["longUrlClicks"].to_f / 100.0).round(2)
      site.checked_at = Time.now

      site.save
    end

    rank = 1
    Site.order("rating desc").each do |site|
      site.update_attribute(:rank, rank)
      rank += 1
    end

    render :text => :OK
  end

  def update_banners
    begin
      Site.all.each do |site|
        site.update_banners
      end

      render :text => :OK
    rescue Exception => $e
      render :text => "Error: #{$e}"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_site
      @site = Site.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def site_params
      params.require(:site).permit(:title, :domain, :referral)
    end
end
