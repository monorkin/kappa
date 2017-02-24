Rails.application.routes.draw do
  root to: 'settings#index'
  resources :settings, except: [:create, :new]
end
