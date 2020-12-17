class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  # before_action :authenticate_user

  # POST /users
  def create
    @user = User.new(user_params)
    @user.validity = true
    @user.user_type = 1
    if @user.save

      wallet = Wallet.create(:user_id => @user.id, :balance => 0).save

      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
