class AdViewsController < ApplicationController
  before_action :set_ad_view, only: [:show, :update, :destroy]
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

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ad_view
    @ad_view = AdView.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def ad_view_params
    params.permit(:user_id, :ad_id, :payable, :promoter_id)
  end
end
