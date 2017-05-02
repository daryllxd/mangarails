Rails.application.routes.draw do
  devise_for :users
resources :mangas, :only => [:index,:chapters] do
  collection do
    get 'chapters'
    get 'downloaded_chapter'
    get 'zip'
  end
end
 root to: 'mangas#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
