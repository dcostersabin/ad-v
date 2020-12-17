require 'rails_helper'

RSpec.describe 'Follower Check', type: :request do

  context 'Follower Controller' do

    it 'Following user without authorization' do
      # this should throw unauthorized response
      post '/users/1/follow', params: { follower: '2' }, as: :json
      expect(response).to have_http_status(401)

    end

    it 'Following user with authorization' do
      # ------------------------------creating one user--------------------------------------------------------
      post '/users', params: { user: { name: "user1", email: "user1@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      user_id_one = JSON.parse(response.body)['id']
      expect(JSON.parse(response.body).size).to eq(8)
      # ---------------------------------------------------------------------------------------------------------
      # ------------------------------create second user---------------------------------------------------------
      post '/users', params: { user: { name: "user2", email: "user2@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      user_id_two = JSON.parse(response.body)['id']
      expect(JSON.parse(response.body).size).to eq(8)
      #------------------------------------------------------------------------------------------------------------
      # -------------------------getting the token of the first user-----------------------------------------------
      post '/user_token', params: { auth: { email: "user1@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
      header_token = JSON.parse(response.body)['jwt']
      # ---------------------------setting the token to the header-------------------------------------------------
      headers = { "Authorization" => "Bearer #{header_token}" }
      # requesting for the follow
      post "/users/#{user_id_one}/follow", params: { "follower": "#{user_id_two}" }, :headers => headers
      expect(response).to have_http_status(:success)
      # -----------------------------------------------------------------------------------------------------------
      # --------------------------------expected success message--------------------------------------------------
      expect(JSON.parse(response.body).size).to eq(2)

    end

    it 'Removing the follow' do
      # ----------------------------------creating one user------------------------------------------------------
      post '/users', params: { user: { name: "user1", email: "user1@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      user_id_one = JSON.parse(response.body)['id']
      expect(JSON.parse(response.body).size).to eq(8)
      #-------------------------------------------------------------------------------------------------------------
      # ------------------------------------create second user---------------------------------------------
      post '/users', params: { user: { name: "user2", email: "user2@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      user_id_two = JSON.parse(response.body)['id']
      expect(JSON.parse(response.body).size).to eq(8)
      #-------------------------------------------------------------------------------------------------------------
      # ----------------------------getting the token of the first user---------------------------------------------
      post '/user_token', params: { auth: { email: "user1@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
      header_token = JSON.parse(response.body)['jwt']
      #---------------------------------------------------------------------------------------------------------------
      # ----------------------------setting the token to the header-------------------------------------------------
      headers = { "Authorization" => "Bearer #{header_token}" }
      # ----------------------------requesting for the follow--------------------------------------------------------
      post "/users/#{user_id_one}/follow", params: { "follower": "#{user_id_two}" }, :headers => headers
      expect(response).to have_http_status(:success)
      # ---------------------------expected success message---------------------------------------------
      expect(JSON.parse(response.body)['message']).to eq('You followed a new  user')
      # ----------------------unfollowing the user with same request---------------------------------------------
      post "/users/#{user_id_one}/follow", params: { "follower": "#{user_id_two}" }, :headers => headers
      expect(response).to have_http_status(:success)
      # ------------------------expected success message---------------------------------------------
      expect(JSON.parse(response.body)['message']).to eq('Follower Removed')
    end

    it 'Following  user with same user id with authorization' do
      # ------------------------creating one user---------------------------------------------
      post '/users', params: { user: { name: "user1", email: "user1@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      user_id_one = JSON.parse(response.body)['id']
      expect(JSON.parse(response.body).size).to eq(8)
      # ------------------------create second user---------------------------------------------
      post '/users', params: { user: { name: "user2", email: "user2@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      user_id_two = JSON.parse(response.body)['id']
      expect(JSON.parse(response.body).size).to eq(8)
      #-------------------------------------------------------------------------------------------------------------
      # --------------------getting the token of the first user---------------------------------------------
      post '/user_token', params: { auth: { email: "user1@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
      header_token = JSON.parse(response.body)['jwt']
      # -------------------setting the token to the header---------------------------------------------
      headers = { "Authorization" => "Bearer #{header_token}" }
      # ----------------------requesting for the follow---------------------------------------------
      post "/users/#{user_id_one}/follow", params: { "follower": "#{user_id_one}" }, :headers => headers
      expect(response).to have_http_status(:success)
      # ------------------expected success message---------------------------------------------
      expect(JSON.parse(response.body)['message']).to eq('Bad Request Please Check The Request Again!')
    end

    it 'Check if the user to be followed has been banned from the site' do
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

      # create user with validity false
      user = User.create(name: 'fakeuser', password_digest: '123123', email: 'fake@gmail.com', validity: false, user_type: '1')
      fake_userid = user.id
      post "/users/#{user_id_one}/follow", params: { "follower": "#{fake_userid}" }, :headers => headers
      expect(response).to have_http_status(:success)
      # should not be able to follow the use
      expect(JSON.parse(response.body)['message']).to eq('User You Are Trying To Follow Has Been Banned From The Site')
    end
  end

end