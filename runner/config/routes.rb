Rails.application.routes.draw do
  root to: 'application#run'
  match '*path', to: 'application#run', via: :all
end
