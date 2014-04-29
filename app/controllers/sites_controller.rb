require "net/http"
require "uri"

class SitesController < ApplicationController
  before_action :set_site, only: [:show, :edit, :update, :destroy, :counter_code]
  skip_before_action :verify_authenticity_token, :only => [:update_rating, :update_rank, :update_banners, :run_delayed_jobs, :update_metrics]

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
      elsif Site.exists?(:domain => @site.domain)
        format.html { redirect_to site_path(Site.find_by(:domain => @site.domain)) }
        format.json { render json: @site.errors, status: :unprocessable_entity }
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

  def counter_code

  end

  def update_banners
    Site.order("rating desc").each do |site|
      site.delay(:priority => 5).update_banners
    end

    render :text => :OK
  rescue Exception => $e
    render :text => "Error: #{$e}"
  end

  def update_rating
    Site.order("rating desc").each do |site|
      site.delay(:priority => 5).update_rating
    end

    render :text => :OK
  rescue Exception => $e
    render :text => "Error: #{$e}"
  end

  def update_rank
    rank = 1

    Site.order("rating desc").each do |site|
      if rank != site.rank
        site.update_attribute(:rank, rank)
        site.delay(:priority => 5).update_banners
      end

      rank += 1
    end

    render :text => :OK
  rescue Exception => $e
    render :text => "Error: #{$e}"
  end

  def run_delayed_jobs
    t = Time.now

    loop do
      break if t < 20.seconds.ago
      results = Delayed::Worker.new.work_off(1) rescue nil

      break if results.sum == 0
    end

    render :text => "OK. Jobs left: #{Delayed::Job.count}"
  rescue Exception => $e
    render :text => "Error: #{$e}"
  end

  def update_metrics
    SimpleMetric::Metric.add_data_point("Sites.count", Time.now, Site.where("rating > 0").count)
    SimpleMetric::Metric.add_data_point("Sites.rating_sum", Time.now, Site.sum(:rating))

    Site.order("rating desc").each do |site|
      site.update_metrics
    end

    render :text => "OK"
  rescue Exception => $e
    render :text => "Error: #{$e}"
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
