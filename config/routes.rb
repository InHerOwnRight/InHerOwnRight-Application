Rails.application.routes.draw do
  get 'images/manifest'
  mount Blacklight::Oembed::Engine, at: 'oembed'
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

  get 'website_search', to: 'website_search#index'
  get 'visualization', to: 'visualization#index'

  ALLOW_ANYTHING_BUT_SLASHES = /[^\/]+/
  constraints id: ALLOW_ANYTHING_BUT_SLASHES, rotation: Riiif::Routes::ALLOW_DOTS, size: Riiif::Routes::SIZES do
    # Route to the IIIF Image API
    get "/iiif/2/:id/:region/:size/:rotation/:quality.:format" => 'riiif/images#show',
      defaults: { format: 'jpg', rotation: '0', region: 'full', size: 'full', quality: 'default', model: 'riiif/image' },
      as: 'riiif_image'

    # Route to IIIF Image API info.json
    get "/iiif/2/:id/info.json" => 'riiif/images#info',
      defaults: { format: 'json', model: 'riiif/image' },
      as: 'riiif_info'

    # Redirect the base route to info.json
    get "/iiif/2/:id", to: redirect("/iiif/2/%{id}/info.json"), as: 'riiif_base'

    # Route to the IIIF manifest.json for a particular image.
    get "iiif/2/:id/manifest.json" => "images#manifest",
      defaults: { format: 'json' },
      as: 'riiif_manifest'
  end

  mount MiradorRails::Engine, at: MiradorRails::Engine.locales_mount_path

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
