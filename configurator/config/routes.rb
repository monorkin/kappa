Rails.application.routes.draw do
  root to: 'template#edit'
  resource :type, only: [:edit, :update], controller: 'type'
  resource :template, only: [:edit, :update], controller: 'template' do
    get 'data'
  end
end
