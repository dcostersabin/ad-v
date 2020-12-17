require 'rails_helper'

RSpec.describe 'Currenct Check', type: :request do
  context 'Currency Controller' do
    it 'Establishing currency' do
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
    end

    it 'Brute Forcing currency' do
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
      #  sending request once more to check if the currency doesnot resets
      post '/currency', :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.body.to_s).to eq('Economy Already Exists')
    end

    it 'Checking Self Sustainability of currency' do
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
      #  modifying currency so that it balances iteself
      current_count = Currency.where(validity: true).count
      last = Currency.last!
      last.validity = false
      last.save
      # database should auto adjust to the change
      currency_count_new = Currency.all.count
      expect(current_count).to eq(200)
      expect(currency_count_new).to be > current_count
    end
  end
end