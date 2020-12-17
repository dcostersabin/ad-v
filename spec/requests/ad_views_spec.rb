require 'rails_helper'

RSpec.describe 'Ad View', type: :request do

  context 'Ad View Contoller' do

    creator_id = 0
    creator_token = ""
    promoter_token = ""
    user_token = ""
    promoter_id = 0
    user_id = 0
    before(:each) do
      #  ---------------------------- Create User ---------------------------------------------------
      post '/users', params: { user: { name: "promoter", email: "user@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      user_id += JSON.parse(response.body)['id']
      # _________________________________________________________________________________________________
      # --------------------getting the token of the User------------------------------------------------
      post '/user_token', params: { auth: { email: "user@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
      header_token1 = JSON.parse(response.body)['jwt']
      # setting the token to the header
      user_token = { "Authorization" => "Bearer #{header_token1}" }
      #---------------------------------------------------------------------------------------------------
      #  ---------------------------- Create Promoter ---------------------------------------------------
      post '/users', params: { user: { name: "promoter", email: "promoter@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      promoter_id += JSON.parse(response.body)['id']
      expect(JSON.parse(response.body).size).to eq(8)
      update_user = User.where(email: 'promoter@gmail.com').first!
      update_user.user_type = 2
      update_user.save
      # _________________________________________________________________________________________________
      # --------------------getting the token of the promoters------------------------------------------------
      post '/user_token', params: { auth: { email: "promoter@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
      header_token3 = JSON.parse(response.body)['jwt']
      # setting the token to the header
      promoter_token = { "Authorization" => "Bearer #{header_token3}" }
      #---------------------------------------------------------------------------------------------------
      #  -------------------------- Create Creator -------------------------------------
      post '/users', params: { user: { name: "creator", email: "creator@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      creator_id = JSON.parse(response.body)['id']
      expect(JSON.parse(response.body).size).to eq(8)
      # update the user as a creator
      update_user = User.where(email: 'creator@gmail.com').first!
      update_user.user_type = 3
      update_user.save
      # update the wallet so that the user has money to post the add
      # --------------------getting the token of the Creator------------------------------------------------
      post '/user_token', params: { auth: { email: "creator@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
      header_token4 = JSON.parse(response.body)['jwt']
      # setting the token to the header
      creator_token = { "Authorization" => "Bearer #{header_token4}" }
      #---------------------------------------------------------------------------------------------------
      wallet = Wallet.where(user_id: update_user.id).first!
      # ad balance greater than 124
      wallet.balance = 500
      wallet.save
      # posting the ad
      # create a file object to send to the request
      clip = Rack::Test::UploadedFile.new("#{Rails.root}/public/vid.mp4", 'video/mp4')
      # ------------------------------ Create First Ad------------------------------------------------
      post '/ads', params: { "title": "this is a title", "description": "this is a description", "clip": clip }, :headers => creator_token
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq('Ad Has Been Posted Successfully')
      #------------------------------------------------------------------------------------------------
      #------------------------------- Create Second Ad -----------------------------------------------
      post '/ads', params: { "title": "this is a title", "description": "this is a description", "clip": clip }, :headers => creator_token
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq('Ad Has Been Posted Successfully')
      # -----------------------------------------------------------------------------------------------
      # # --------------------------- promoters Follows creator -----------------------------------------
      post "/users/#{promoter_id}/follow", params: { "follower": "#{creator_id}" }, :headers => promoter_token
      expect(response).to have_http_status(:success)
      # expected success message
      expect(JSON.parse(response.body)['message']).to eq('You followed a new  user')
      # # -------------------------------------------------------------------------------------------------
      #  ---------------------------- Get Promotable Ads --------------------------------------------------
      get '/ads/view_all', params: {}, :headers => promoter_token
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(2)
      # getting ad id from the available ads
      ad_id = JSON.parse(response.body)[0]['id']
      # ---------------------------------------------------------------------------------------------------
      #  ------------------------------- Send Request -------------------------------------------------------
      post '/ads/request_ad', params: { "id": "#{ad_id}" }, :headers => promoter_token
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq('Creator is notified')
      #  ------------------------------------------------------------------------------------------------------
    end

    it 'View Ads To User' do

      # --------------------------pre condition ------------------------------------------------------
      # ---------------------------------get all the requests-----------------------------------------------
      get '/ads/view_requested', params: {}, :headers => creator_token
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
      # ------------------------------------------------------------------------------------------------------
      #  --------------------------------accept any one-----------------------------------
      request_id = JSON.parse(response.body)[0]['id']
      put '/ads/approve', params: { "id": "#{request_id}" }, :headers => creator_token
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq('Request Has Been Approved')
      #  ---------------------------------------------------------------------------------
      # ----------------------------------------------------------------------------------------------
      # -------------------------- Following some promoter ---------------------------------------------
      post "/users/#{user_id}/follow", params: { "follower": "#{promoter_id}" }, :headers => user_token
      expect(response).to have_http_status(:success)
      # ---------------------------expected success message---------------------------------------------
      expect(JSON.parse(response.body)['message']).to eq('You followed a new  user')
      #  ----------------------------- getting the ads -----------------------------------------------
      get '/ads/view_all', params: {}, :headers => user_token
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
    end



    it 'promoter accepts the request' do
      # ---------------------------------get all the requests-----------------------------------------------
      get '/ads/view_requested', params: {}, :headers => creator_token
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
      # ------------------------------------------------------------------------------------------------------
      #  --------------------------------accept any one-----------------------------------
      request_id = JSON.parse(response.body)[0]['id']
      put '/ads/approve', params: { "id": "#{request_id}" }, :headers => creator_token
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq('Request Has Been Approved')
      #  ---------------------------------------------------------------------------------
    end

  end
end