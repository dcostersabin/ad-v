Rails.application.routes.draw do

  # for creators only
  post 'ads' => 'ads#create' #tested
  # for promoters only
  post 'ads/request_ad' => 'ad_requests#create'  #tested
  # for creators only
  get 'ads/view_requested' => 'ad_requests#index' #tested
  # for promoters only
  get 'ads/view_all' => 'ads#index'      #tested
  # for all users
  post 'user_token' => 'user_token#create' #tested
  # for users only
  get 'ads/view/:id' => 'ads#show' #tested
  # for creators only
  put 'ads/approve' => 'ad_requests#update'   #tested
  # for all users
  post 'topup' => 'wallets#update' #tested
  # for user only
  post 'ads/pay_user' => 'ad_views#pay_user'  #tested
  # for admins only for starting economy
  post '/currency' => 'currencies#start_economy' #tested
  # # for following user

  resources :users do
    post 'follow' => 'followers#follow' #tested
    post 'wallet' => 'wallets#show' #tested
  end

end
