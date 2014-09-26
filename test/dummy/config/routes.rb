Rails.application.routes.draw do
  root to: 'static#home'
  get 'static/home'
  resources :articles
end
