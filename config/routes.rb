Rails.application.routes.draw do
  mount Blacklight::Engine => '/'
  root to: 'spotlight/exhibits#index'
  mount Spotlight::Engine, at: 'spotlight'
#  root to: "catalog#index" # replaced by spotlight root path

  mount Riiif::Engine => '/uploads/spotlight/temporary_image/image', as: 'riiif'
  concern :searchable, Blacklight::Routes::Searchable.new
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

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

  resource :home, only: [:index], as: 'home', path: '/', controller: 'home'
#  root to: "home#index" # replaced by spotlight root path

  resources :oai, only: [:index], controller: 'pacscl_oai'

  get '/process_images', to: 'process_images#index'
  post '/process_images', to: 'process_images#create'
  get '/import_record_collections', to: 'import_record_collections#index'
  post '/import_record_collections', to: 'import_record_collections#create'
  get '/import_pacscl_collections', to: 'import_pacscl_collections#index'
  post '/import_pacscl_collections', to: 'import_pacscl_collections#create'

  resources :csv_harvests, only: [:index, :create] do
    resources :records, only: [:index]
  end

  resources :oai_harvests, only: [:index, :create] do
    resources :records, only: [:index]
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
