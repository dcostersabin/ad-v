Rails.application.routes.draw do

  resources :wallets
  resources :attachments
  post 'user_token' => 'user_token#create'
  resources :users do
    post 'follow' => 'followers#follow'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
