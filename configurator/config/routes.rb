Rails.application.routes.draw do
  root to: 'landing#show'
  resource :type, only: [:edit, :update], controller: 'type'
  resource :template, only: [:edit, :update], controller: 'template' do
    get 'data'
  end
end
