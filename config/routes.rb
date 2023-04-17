Rails.application.routes.draw do
  devise_for :users
  
  root to: "pages#home"

  #resources :quotes
  resources :quotes do
    resources :line_item_dates, except: [:index, :show]
  end
end
