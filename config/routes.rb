Rails.application.routes.draw do

  # for creators only
  post 'ads' => 'ads#create'
  # for promoters only
  post 'ads/request_ad' => 'ad_requests#create'
  # for promoters only
  get 'ads/view_promotable' => 'ads#index'
  # for creators only
  get 'ads/view_requested' => 'ad_requests#index'
  # for promoters only
  get 'ads/view_all' => 'ads#index'
  # for all users
  post 'user_token' => 'user_token#create'
  # for users only
  get 'ads/view_all' => 'ads#index'
  # for creators only
  put 'ads/approve' => 'ad_requests#update'
  resources :users do
    # for all users
    post 'follow' => 'followers#follow'
  end
end
