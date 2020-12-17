class CurrenciesController < ApplicationController
  before_action :load_wallet, only: [:update_wallet]
  before_action :authenticate_user

  def start_economy
    if current_user.user_type == 4
      # count the hash if no hash are present initialize has for the economy
      hash_count = Currency.all.count
      if hash_count == 0
        #    genereate hash for 200 units so that value is maintaned
        200.times do
          # getting the hash
          hashed = generate_hash.to_s
          # creating currencies to work on
          single_currency = Currency.create(:hash_digest => hashed, :validity => true)
        end
        render json: 'Economy started'
      else
        render json: 'Economy Already Exists'
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

  def generate_hash
    # taking time as random key
    key = Time.now.to_s + "#{rand(0..1000)}"
    # taking time of last month and random number as the data to be encoded
    data = Time.now.last_month.to_s + "#{rand(0..2000)}"
    # generating digest for sha256
    digest = OpenSSL::Digest.new('sha256')
    # converting the digest to hmax hex digest
    hashed = OpenSSL::HMAC.hexdigest(digest, key, data)
  end
end
