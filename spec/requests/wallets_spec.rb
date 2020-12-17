require 'rails_helper'

RSpec.describe "Wallet Controller Test", type: :request do
  context 'Wallet Creation' do
    it 'Check Wallet is created at user creation' do
      # create a fake user so that the token can be accessed
      post '/users', params: { user: { name: "dcosasdf", email: "user11@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(8)
      # get the user instance
      user = User.where(email: 'user11@gmail.com').first!
      wallet = Wallet.where(user_id: user.id).exists?
      expect(wallet).to eq(true)
    end

    it 'Check Balance Of Current User' do
      # creating one user
      post '/users', params: { user: { name: "user1", email: "user1@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      user_id_one = JSON.parse(response.body)['id']
      expect(JSON.parse(response.body).size).to eq(8)
      # getting the token of the first user
      post '/user_token', params: { auth: { email: "user1@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
      header_token = JSON.parse(response.body)['jwt']
      # setting the token to the header
      headers = { "Authorization" => "Bearer #{header_token}" }
      post "/users/#{user_id_one}/wallet", :headers => headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(5)
    end

    it 'Check Wallet Top Up With Valid Hash' do
      # ------------------------------------ Create Economy for topup--------------------------------------------
      # create a fake user so that the token can be accessed
      post '/users', params: { user: { name: "dcosasdf", email: "user11@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(8)
      # get the user instance
      user = User.where(email: 'user11@gmail.com').first!
      user.user_type = 4
      user.save
      # send request for authentication token
      # getting the token of the first user
      post '/user_token', params: { auth: { email: "user11@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
      header_token = JSON.parse(response.body)['jwt']
      # setting the token to the header
      headers = { "Authorization" => "Bearer #{header_token}" }
      # start the economy as the super user
      post '/currency', :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body.to_s).to eq('Economy started')
      # --------------------------------------------------------------------------------------------------------------
      # top up balance of created user from the economy hash
      top_up_hash = Currency.last!
      post '/topup', params: { "hash": "#{top_up_hash.hash_digest}" }, :headers => headers
      expect(response).to have_http_status(:success)
      #   verify if the wallet has been toped up
      wallet = user.wallet.balance
      expect(wallet).to be(500.to_f)
    end

    it 'Check Wallet Top Up With Invalid Hash' do
      # ------------------------------------ Create Economy for topup--------------------------------------------
      # create a fake user so that the token can be accessed
      post '/users', params: { user: { name: "dcosasdf", email: "user11@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(8)
      # get the user instance
      user = User.where(email: 'user11@gmail.com').first!
      user.user_type = 4
      user.save
      # send request for authentication token
      # getting the token of the first user
      post '/user_token', params: { auth: { email: "user11@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
      header_token = JSON.parse(response.body)['jwt']
      # setting the token to the header
      headers = { "Authorization" => "Bearer #{header_token}" }
      # start the economy as the super user
      post '/currency', :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body.to_s).to eq('Economy started')
      # --------------------------------------------------------------------------------------------------------------
      # top up balance of created user from the economy hash
      top_up_hash = "woeruopqwe1203410-28934alsdkfjasdf"
      post '/topup', params: { "hash": "#{top_up_hash}" }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq('Bad Request Please Check The Request Again!')
    end

  end
end