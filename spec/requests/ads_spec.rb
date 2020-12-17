require 'rails_helper'

RSpec.describe "Ads", type: :request do
  context 'Ads Controller' do

    it 'Create Ad With Valid Paramrter' do
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
      # update the user as a creator
      update_user = User.where(email: 'user1@gmail.com').first!
      update_user.user_type = 3
      update_user.save
      # update the wallet so that the user has money to post the add
      wallet = Wallet.where(user_id: update_user.id).first!
      # ad balance greater thatn 124
      wallet.balance = 500
      wallet.save
      # posting the ad
      # create a file object to send to the request
      clip = Rack::Test::UploadedFile.new("#{Rails.root}/public/vid.mp4", 'video/mp4')
      post '/ads', params: { "title": "this is a title", "description": "this is a description", "clip": clip }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq('Ad Has Been Posted Successfully')
    end

    it 'Create Ad Without clip' do
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
      # update the user as a creator
      update_user = User.where(email: 'user1@gmail.com').first!
      update_user.user_type = 3
      update_user.save
      # update the wallet so that the user has money to post the add
      wallet = Wallet.where(user_id: update_user.id).first!
      # ad balance greater thatn 124
      wallet.balance = 500
      wallet.save
      # posting the ad
      # create a file object to send to the request
      post '/ads', params: { "title": "this is a title", "description": "this is a description" }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq('Bad Request Please Check The Request Again!')
    end

    it 'Create Ad Without title and description Paramrter' do
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
      # update the user as a creator
      update_user = User.where(email: 'user1@gmail.com').first!
      update_user.user_type = 3
      update_user.save
      # update the wallet so that the user has money to post the add
      update_user.wallet.balance += 500
      update_user.wallet.save
      # posting the ad
      # create a file object to send to the request
      clip = Rack::Test::UploadedFile.new("#{Rails.root}/public/vid.mp4", 'video/mp4')
      # posting without title
      post '/ads', params: { "description": "this is a description", "clip": clip }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq('Bad Request Please Check The Request Again!')
      # posting without description
      post '/ads', params: { "title": "this is a title", "clip": clip }, :headers => headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq('Bad Request Please Check The Request Again!')
    end



  end


end