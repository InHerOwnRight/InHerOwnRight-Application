Rails.application.routes.draw do

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  resources :records, only: [:show], param: :oai_identifier

  mount Blacklight::Engine => '/'
  resource :home, only: [:index], as: 'home', path: '/', controller: 'home'
  root to: "home#index"

  resources :oai, only: [:index], controller: 'pacscl_oai'

  get '/process_images', to: 'process_images#index'
  post '/process_images', to: 'process_images#create'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
