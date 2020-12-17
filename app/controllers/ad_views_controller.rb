class AdViewsController < ApplicationController
  before_action :set_ad_view, only: [:show]
  before_action :set_wallet, :user_cut, only: [:pay_user]
  before_action :authenticate_user

  # GET /ad_views
  def index
    @ad_views = AdView.all

    render json: @ad_views
  end

  # GET /ad_views/1
  def show
    render json: @ad_view
  end

  # POST /ad_views
  def create
    @ad_view = AdView.new(ad_view_params)

    if @ad_view.save
      render json: @ad_view, status: :created, location: @ad_view
    else
      render json: @ad_view.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /ad_views/1
  def update
    if @ad_view.update(ad_view_params)
      render json: @ad_view
    else
      render json: @ad_view.errors, status: :unprocessable_entity
    end
  end

  # DELETE /ad_views/1
  def destroy
    @ad_view.destroy
  end

  # update if the user has viewed the add for full payment
  def pay_user
    # only user having type 1 can get paid for viewing the ad
    if current_user.user_type == 1
      # check the request has promoters id and ad id
      if params.key?('ad_id') && params.key?('promoters_id')
        #  fetch if the corresponding ids are paid or not
        begin
          # getting the instance if the user has record on views list that is unpaid
          user_view = AdView.where(:user_id => current_user.id, promoter_id: params[:promoters_id], payable: false).first!
          # updating the wallet
          @wallet.balance += @cut
          # updating the status to paid
          user_view.payable = true
          # if both transaction successfully executes then send success request
          if @wallet.save && user_view.save
            # success message
            render json: "Wallet Updated By #{@cut}"
          end
        rescue ActiveRecord::RecordNotFound => e
          bad_request
        end

      else
        bad_request
      end
    else
      bad_request
    end
  end

  private

  # returns bad request error
  def bad_request
    render json: { "status": 400, "message": 'Bad Request Please Check The Request Again!' }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_ad_view
    @ad_view = AdView.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def ad_view_params
    params.permit(:user_id, :ad_id, :payable, :promoter_id)
  end

  # set wallet for payments per view
  def set_wallet
    @wallet = Wallet.where(user_id: current_user.id).first!
  end

  def user_cut
    @cut = 0.4 * 0.00625
  end
end
