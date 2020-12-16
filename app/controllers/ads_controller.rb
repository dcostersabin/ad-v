# frozen_string_literal: true
class AdsController < ApplicationController
  include Rails.application.routes.url_helpers

  before_action :set_ad, only: %i[show update]
  before_action :authenticate_user

  # view published ads by the creators
  def index

    case current_user.user_type
      # when user is promoter
    when 2
      ads = Ad.where(validity: true)
      render json: ads
      # when user is creator
    when 3
      ads = Ad.where(creator_id: current_user.id)
      render json: ads
      # where user is viewer
    when 1
      #  check which ads are available
      promoters_all = User.where(user_type: 2)
      # get the promoters they are following
      following_promoters = Follower.where(user_id: current_user.id, following: promoters_all.ids).pluck(:following)
      # getting availabel ads from the promoters
      promoters_with_ad = AdRequest.where(promoter_id: following_promoters, accepted: true, paid: false )
      # creating hash
      viewable_ads = {}
      # creating counter for unique hash key
      ad_counter = 0
      # looping over the promoters to get the ads
      promoters_with_ad.each do |promters|
        ad_counter += 1
        ads_detail = Ad.find(promters.ad_id)
        # getting promoters info for who's add is this
        promoters_info = User.find(promters.promoter_id)
        # appending ad list to hash
        viewable_ads.merge!({ ad_counter.to_s => { promoters_info.email => ads_detail, 'promoter_id' => promoters_info.id } })
      end
      render json: viewable_ads

    else
      bad_request
    end

  end

  # POST /ads
  def create

    if (current_user.user_type == 3) && (current_user.wallet.balance >= 125)
      acceptable_types = ['video/mpeg', 'video/mp4']
      @ad = Ad.new(ad_params)
      # setting validity to true for every new instance
      @ad.validity = true
      # taking userid from the request sent not the params
      @ad.creator_id = current_user.id
      # check if the params array has clip key initialized
      if params.key?('clip')
        if acceptable_types.include?(@ad.clip.content_type)
          if @ad.save
            # updating the user balance
            wallet = Wallet.find(current_user.wallet.id)
            wallet.balance = wallet.balance - 125
            wallet.save
            success('Ad Has Been Posted Successfully')
          else
            # send bad request if there is some error while saving the ad
            bad_request
          end
        else
          # send bad request if the provided clip is not valid
          bad_request
        end
      else
        # if clip is not initialized send bad request
        bad_request
      end

    else
      bad_request
    end

  end

  # show individual add to only users
  def show
    if current_user.user_type == 1
      paid_status = false
      clip_url = rails_blob_path(@ad.clip, disposition: 'attachment', only_path: true)
      viewable = { 'description' => @ad, 'url' => clip_url, "paid_status": paid_status }
      # check if promoter is still unpaid and exists for the given add
      promoter_check = AdRequest.where(ad_id: params[:id], promoter_id: params[:promoters_id], paid: false).exists?
      if promoter_check
        #  check if the user has already viewed the add
        user_ad_view_check = AdView.where(ad_id: params[:id], user_id: current_user.id).exists?
        if user_ad_view_check
          #  check if the user is paid or not if paid reject else provide the link
          user_paid = AdView.where(ad_id: params[:id], user_id: current_user.id).first!
          viewable['paid_status'] = true if user_paid.payable
          render json: viewable
        else
          # create new instance that user has viewed the ad
          viewed_ad = AdView.new
          viewed_ad.user_id = current_user.id
          viewed_ad.promoter_id = params[:promoters_id]
          viewed_ad.ad_id = @ad.id
          viewed_ad.payable = false
          if viewed_ad.save
            # updating promoters wallet for the views added
            promoters_update = promoters_wallet
            # adding the promoters cut
            promoters_update.balance += promoters_cut
            promoters_update.save
            render json: viewable
          else
            bad_request
          end

        end
      else
        bad_request
      end

    else
      bad_request
    end
  end

  # sending bad request
  def bad_request
    render json: { "status": 400, "message": 'Bad Request Please Check The Request Again!' }
  end

  # sending any success messages
  def success(msg)
    render json: { "status": 'Success!', "message": msg }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ad
    limit = 1
    # decline request with invalid id
    if params.key?('promoters_id') && User.where(id: params[:promoters_id]).exists?
      begin
        # check if the ad give exists
        @ad = Ad.find(params[:id])
        # check if the ad has reached 10K views if so disable all the visibility
        ad_count = AdView.where(ad_id: @ad.id).count
        if ad_count >= limit
          @ad.validity = false
          @ad.save
          # get all the ad request and set them to paid
          ad_requests = AdRequest.where(ad_id: @ad)
          ad_requests.each do |request|
            request.paid = true
            request.save
          end
        end
      rescue ActiveRecord::RecordNotFound => e
        bad_request
      end
    else
      bad_request
    end

  end

  # Only allow a trusted parameter "white list" through.
  def ad_params
    params.permit(:title, :description, :validity, :clip)
  end

  def promoters_cut
    @cut = 0.6 * 0.00625
  end

  def promoters_wallet
    Wallet.find(params[:promoters_id])
  end

end
