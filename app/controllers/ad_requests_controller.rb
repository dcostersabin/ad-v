class AdRequestsController < ApplicationController
  before_action :set_ad_request, only: [:show, :update, :destroy]

  # GET /ad_requests
  def index
    if current_user.user_type == 3
      @ad_requests = AdRequest.where(:accepted => false)
      render json: @ad_requests
    else
      bad_request
    end

  end

  # GET /ad_requests/1
  def show
    render json: @ad_request
  end

  # POST /ad_requests
  def create
    # check if the user is promoter and if they pass ad id
    if (current_user.user_type == 2) && (params.key?('id'))
      # checking if the ad is valid or not
      begin
        # getting the requested add
        ad_check = Ad.find(params[:id])
        # check if the promoter is following the creator and the ad is valid
        following_check = Follower.where(:user_id => current_user.id, :following => ad_check.creator_id).exists?
        # check if the promoter has already requested to promote
        promoter_check = AdRequest.where(:promoter_id => current_user.id, :ad_id => params[:id]).exists?
        if following_check && ad_check.validity && !promoter_check
          #  if the user is following and the ad is valid then create request instance
          request = AdRequest.create(:ad_id => ad_check.id, :promoter_id => current_user.id, :paid => false, :accepted => false)
          if request
            success('Creator is notified')
          else
            # bad_request
            success('a')
          end
        else
          bad_request
        end
      rescue ActiveRecord::RecordNotFound => e
        # if the record is not found then create a bad request response
        bad_request
      end

    else
      bad_request
    end
  end

  # PATCH/PUT /ad_requests/1
  def update
    # check if the current user is creator of that ad
    begin
      check_creator = Ad.find(@ad_request.ad_id)
      if check_creator.creator_id == current_user.id
        @ad_request.accepted = true
        if @ad_request.save
          success("Request Has Been Approved")
        else
          bad_request
        end
      else
        bad_request
      end
    rescue ActiveRecord::RecordNotFound => e
      bad_request
    end

  end

  # DELETE /ad_requests/1
  def destroy
    @ad_request.destroy
  end

  # returns bad request error
  def bad_request
    render json: { "status": 400, "message": 'Bad Request Please Check The Request Again!' }
  end

  # return a success message
  def success(msg)
    render json: { "status": 'Success!', "message": msg }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ad_request
    begin
      @ad_request = AdRequest.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      bad_request
    end

  end

  # Only allow a trusted parameter "white list" through.
  def ad_request_params
    params.require(:ad_request).permit(:promoter_id, :ad_id, :accepted, :paid)
  end
end
