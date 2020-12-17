class WalletsController < ApplicationController
  before_action :set_wallet, only: [:show, :update, :destroy]
  before_action :authenticate_user

  # GET /wallets/1
  def show
    render json: @wallet
  end

  # POST /wallets
  def create
    @wallet = Wallet.new(wallet_params)

    if @wallet.save
      render json: @wallet, status: :created, location: @wallet
    else
      render json: @wallet.errors, status: :unprocessable_entity
    end
  end

  def update
    if params.key?('hash')
      #   check if the hash is in the database
      exisits = Currency.where(:hash_digest => params[:hash], :validity => true).exists?
      if exisits
        @wallet.balance += 500
        #  disable the curreny before transaction is commited
        currency = Currency.where(:hash_digest => params[:hash], :validity => true).first!
        currency.validity = false
        if currency.save && @wallet.save
          render json: 'Wallet Updated By 500'
        else
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
  def set_wallet
    @wallet = Wallet.where(user_id: current_user.id).first!
  end

  # Only allow a trusted parameter "white list" through.
  def wallet_params
    params.require(:wallet).permit(:user_id, :balance)
  end
end
