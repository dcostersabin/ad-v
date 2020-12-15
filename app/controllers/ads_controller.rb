class AdsController < ApplicationController
  before_action :set_ad, only: [:show, :update, :destroy]
  before_action :authenticate_user
  include Rails.application.routes.url_helpers

  # view published ads by the creators
  def index

    case current_user.user_type
      # when user is promoter
    when 2
      ads = Ad.where(:validity => true)
      render json: ads
      # when user is creator
    when 3
      ads = Ad.where(:creator_id => current_user.id)
      render json: ads
      # where user is viewer
    when 1
      #  check which ads are available
      promoters_all = User.where(:user_type => 2)
      # get the promoters they are following
      following_promoters = Follower.where(:user_id => current_user.id, :following => promoters_all.ids).pluck(:following)
      # getting availabel ads from the promoters
      promoters_with_ad = AdRequest.where(:promoter_id => following_promoters, :accepted => true)
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
        viewable_ads.merge!({ ad_counter => { promoters_info.email => ads_detail } })
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
            success("Ad Has Been Posted Successfully")
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
    @ad = Ad.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def ad_params
    params.permit(:title, :description, :validity, :clip)
  end

end
