require 'rails_helper'

RSpec.describe "User Controller Test", type: :request do
  context 'User Creation' do



    # tesing user creation with valid parameter
    it 'Create User With Valid Parameters' do
      # create a fake user so that the token can be accessed
      post '/users', params: { user: { name: "dcosasdf", email: "user11@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(8)
    end

    # this test should give error
    it 'Create User With name only' do
      post '/users', params: { user: { name: "asdf" } }, as: :json
      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body).size).to eq(3)
    end

    # this test should give error
    it 'Create User With email only' do
      post '/users', params: { user: { email: "user11@gmail.com" } }, as: :json
      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body).size).to eq(3)
    end

    # this test should give error
    it 'Create User With password only' do
      post '/users', params: { user: { password: "123" } }, as: :json
      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body).size).to eq(2)
    end

  end

  context 'User Token' do
    it 'Return JWT' do
      # first create a user
      post '/users', params: { user: { name: "dcosasdf", email: "user11@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(8)
      # then access the token that is generated for further authentication
      post '/user_token', params: { auth: { email: "user11@gmail.com", password: "dcoster123" } }, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

end